c      include "experimental/rans_komg.f"    ! core/experimental
c
      subroutine dumpCFLYpWSS
      implicit none

      include 'SIZE'
      include 'TOTAL'

      logical ifxyo_s,ifpo_s,ifvo_s,ifto_s,ifpsco_s(ldimt1)

      integer i,n
      real tsv(lx1*ly1*lz1*lelv,ldimt),cdum,psv(lx2,ly2,lz2,lelv)
      real wd(lx1*ly1*lz1*lelv)

      n = lx1*ly1*lz1*nelv

      ifxyo_s = ifxyo
      ifpo_s = ifpo
      ifvo_s = ifvo
      ifto_s = ifto
      do i=1,ldimt1
        ifpsco_s(i)=ifpsco(i)
      enddo

      ifxyo=.true.
      ifpo=.false.
      ifvo=.false.
      ifto=.true.
      ifpsco(1)=.true.
      ifpsco(2)=.true.
      do i=3,ldimt1
        ifpsco(i)=.false.
      enddo

      call copy(tsv(1,1),t,n)
      call compute_cfl(cdum,vx,vy,vz,dt)
      call copy(t,cflf,n)

      call copy(tsv(1,2),t(1,1,1,1,2),n)
      call get_wall_distance(wd,2)
      call get_y_p(wd,t(1,1,1,1,2),.true.)
      call get_wss(wd,t(1,1,1,1,3),.true.)      

      call prepost (.true.,'emt')


      call get_y_p(wd,t(1,1,1,1,2),.false.)
      call get_wss(wd,t(1,1,1,1,3),.false.)

      call prepost (.true.,'mtr')


      call copy(t,tsv,n)
      call copy(t(1,1,1,1,2),tsv(1,2),n)
      if(ifsplit) call copy(pr,psv,n)

      ifxyo = ifxyo_s
      ifpo = ifpo_s
      ifvo = ifvo_s
      ifto = ifto_s
      do i=1,ldimt1
        ifpsco(i)=ifpsco_s(i)
      enddo

      return
      end
c---------------------------------------------------------
      subroutine dumpY
      implicit none

      include 'SIZE'
      include 'TOTAL'

      logical ifxyo_s,ifpo_s,ifvo_s,ifto_s,ifpsco_s(ldimt1)

      integer i,n
      real tsv(lx1*ly1*lz1*lelv,ldimt),cdum,psv(lx2,ly2,lz2,lelv)
      real wd(lx1*ly1*lz1*lelv)

      n = lx1*ly1*lz1*nelv

c      ifxyo_s = ifxyo
c      ifpo_s = ifpo
c      ifvo_s = ifvo
c      ifto_s = ifto
c      do i=1,ldimt1
c        ifpsco_s(i)=ifpsco(i)
c      enddo

      ifxyo=.true.
      ifpo=.true.
      ifvo=.true.
      ifto=.true.
      ifpsco(1)=.true. !lamda2
      ifpsco(2)=.true. !distance

      do i=3,ldimt1
        ifpsco_s(i)=ifpsco(i)
      enddo

      call get_wall_distance(wd,2)



      call copy(t(1,1,1,1,3),wd,n)
      call prepost (.true.,'dst')


      return
      end

c-----------------------------------------------------------------------
      subroutine get_y_p(wd,phi,ifelem)
      include 'SIZE'
      include 'TOTAL'
C
C     Computes yplus
C
      logical ifelem

      real wd(lx1,ly1,lz1,*),phi(lx1,ly1,lz1,*)

      integer e,i,i0,i1,j,j0,j1,k,k0,k1,ib,jb,kb,i2,j2
      integer ipt,isd
c     real msk(lx1,ly1,lz1,lelv)
      real gradu(lx1*ly1*lz1,3,3)
      real tau(3),norm(3),vsca,tauw,dist
      real utau,rho,mu,yp,yp0,vol
      real glmin,glmax,glsum
      logical ifgrad, ifdid

      call rzero(phi,lx1*ly1*lz1*nelv)
      do e=1,nelv
        yp=0.0
        vol=1.0e-20
        ifgrad=.true.
        do isd=1,2*ndim
          if(cbc(isd,e,1).eq.'W  ')then
            if(ifgrad)then
              call gradm11(gradu(1,1,1),gradu(1,1,2),gradu(1,1,3),vx,e)
              call gradm11(gradu(1,2,1),gradu(1,2,2),gradu(1,2,3),vy,e)
              if(if3d)
     &         call gradm11(gradu(1,3,1),gradu(1,3,2),gradu(1,3,3),vz,e)
              ifgrad=.false.
            endif
            call facind(i0,i1,j0,j1,k0,k1,lx1,ly1,lz1,isd)
            do 50 k=k0,k1
            do 50 j=j0,j1
            do 50 i=i0,i1
              kb=k
              jb=j
              ib=i
              if    (isd.eq.1) then
                jb=2
              elseif(isd.eq.2) then
                ib=lx1-1
              elseif(isd.eq.3) then
                jb=ly1-1
              elseif(isd.eq.4) then
                ib=2
              elseif(isd.eq.5) then
                kb=2
              else
                kb=lz1-1
              endif
              dist=wd(ib,jb,kb,e)
              if(dist.gt.1.0e-12) then
                ipt=i+(j-1)*lx1+(k-1)*lx1*ly1
                call getSnormal(norm,i,j,k,isd,e)
                mu=vdiff(i,j,k,e,1)
                rho=vtrans(i,j,k,e,1)

                do i2=1,ldim
                tau(i2)=0.0
                  do j2=1,ldim
                    tau(i2)=tau(i2)+
     &                   mu*(gradu(ipt,i2,j2)+gradu(ipt,j2,i2))*norm(j2)
                  enddo
                enddo

                vsca=0.0
                do i2=1,ldim
                  vsca=vsca+tau(i2)*norm(i2)
                enddo

                tauw=0.0
                do i2=1,ldim
                  tauw=tauw+(tau(i2)-vsca*norm(i2))**2
                enddo
                if(tauw.gt.0.0) then
                  tauw=sqrt(tauw)
                  utau=sqrt(tauw/rho)
                else
                  tauw=0.0
                  utau=0.0
                endif

                yp0=dist*utau*rho/mu
                yp=yp+yp0*bm1(i,j,k,e)
                phi(i,j,k,e)=yp0
                vol=vol+bm1(i,j,k,e)



              endif
  50        continue
          endif
        enddo
        if(ifelem) call cfill(phi(1,1,1,e),yp/vol,lx1*ly1*lz1)
      enddo

      return
      end
C-----------------------------------------------------------------------
      subroutine get_wss(wd,phi,ifelem)
      include 'SIZE'
      include 'TOTAL'
C
C     Computes wall-shear stress
C
      logical ifelem

      real wd(lx1,ly1,lz1,*),phi(lx1,ly1,lz1,*)

      integer e,i,i0,i1,j,j0,j1,k,k0,k1,ib,jb,kb,i2,j2
      integer ipt,isd
c     real msk(lx1,ly1,lz1,lelv)
      real gradu(lx1*ly1*lz1,3,3)
      real tau(3),norm(3),vsca,tauw,dist
      real utau,rho,mu,yp,vol, yp0
      real glmin,glmax,glsum
      logical ifgrad, ifdid

      call rzero(phi,lx1*ly1*lz1*nelv)
      do e=1,nelv
        yp=0.0
        vol=1.0e-20
        ifgrad=.true.
        do isd=1,2*ndim
          if(cbc(isd,e,1).eq.'W  ')then
            if(ifgrad)then
              call gradm11(gradu(1,1,1),gradu(1,1,2),gradu(1,1,3),vx,e)
              call gradm11(gradu(1,2,1),gradu(1,2,2),gradu(1,2,3),vy,e)
              if(if3d)
     &         call gradm11(gradu(1,3,1),gradu(1,3,2),gradu(1,3,3),vz,e)
              ifgrad=.false.
            endif
            call facind(i0,i1,j0,j1,k0,k1,lx1,ly1,lz1,isd)
            do 50 k=k0,k1
            do 50 j=j0,j1
            do 50 i=i0,i1
              kb=k
              jb=j
              ib=i
              if    (isd.eq.1) then
                jb=2
              elseif(isd.eq.2) then
                ib=lx1-1
              elseif(isd.eq.3) then
                jb=ly1-1
              elseif(isd.eq.4) then
                ib=2
              elseif(isd.eq.5) then
                kb=2
              else
                kb=lz1-1
              endif
              dist=wd(ib,jb,kb,e)
              if(dist.gt.1.0e-12) then
                ipt=i+(j-1)*lx1+(k-1)*lx1*ly1
                call getSnormal(norm,i,j,k,isd,e)
                mu=vdiff(i,j,k,e,1)
                rho=vtrans(i,j,k,e,1)

                do i2=1,ldim
                tau(i2)=0.0
                  do j2=1,ldim
                    tau(i2)=tau(i2)+
     &                   mu*(gradu(ipt,i2,j2)+gradu(ipt,j2,i2))*norm(j2)
                  enddo
                enddo

                vsca=0.0
                do i2=1,ldim
                  vsca=vsca+tau(i2)*norm(i2)
                enddo

                tauw=0.0
                do i2=1,ldim
                  tauw=tauw+(tau(i2)-vsca*norm(i2))**2
                enddo
                if(tauw.gt.0.0) then
                  tauw=sqrt(tauw)
                  utau=sqrt(tauw/rho)
                else
                  tauw=0.0
                endif
                !DKF
                yp0=tauw
                yp=yp+yp0*bm1(i,j,k,e)
                phi(i,j,k,e)=yp0
                vol=vol+bm1(i,j,k,e)


              endif
  50        continue
          endif
        enddo
        if(ifelem) call cfill(phi(1,1,1,e),yp/vol,lx1*ly1*lz1)
      enddo

      return
      end
C-----------------------------------------------------------------------

      subroutine get_wall_distance(wd,itype)
      include 'SIZE'

      real wd(*)
      real w1(lx1*ly1*lz1*lelv)
      real w2(lx1*ly1*lz1*lelv)
      real w3(lx1*ly1*lz1*lelv)
      real w4(lx1*ly1*lz1*lelv)
      real w5(lx1*ly1*lz1*lelv)
      common /SCRNS/ w1,w2,w3,w4,w5

      if(itype.eq.1) then
        call cheap_dist(wd,1,'W  ')
      elseif(itype.eq.2) then
        call distf(wd,1,'W  ',w1,w2,w3,w4,w5)
      else
        if(nio.eq.0) write(*,*)
     &           "Error in get_wall_distance, unsupported distance type"
      endif

      return
      end
C-----------------------------------------------------------------------
