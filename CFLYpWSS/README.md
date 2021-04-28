# Save CFL, Y+ and wall-shear stress.
## Information
A tool that computes the local CFLi (Courant–Friedrichs–Lewy), 
Y+ and wall-shear stress values and store them in fld files.


The CFL (Courant–Friedrichs–Lewy) values are computed in all GLL points and 
get stored in the "temperature" field.

Two kind of computations are performed for Y+ and wall-shear-stress:
1. computation over all GLL-points on wall elements (cbc(i,j,k,e) = 'W   ').
    Results are stored in a file named 'emt$case_name$0.fld*'
2. face-averaged computations over each element's face with wall boundary condition
   (cbc(i,j,k,e) = 'W  '). Results are stored in a file named 'mtr$case_name$0.fld*'

Y+ values are  stored in the scalar #1 (s1) field. 
Local wall shear stress is stored in the scalar #2 (s2).

## Use
1. Include dumpCFLYpWSS.f in your .usr file
2. call dumpmeCFLYpWSS.f in usrcheck (I would do this either as post-processing or every n_output time step). 
3. This will produce a set of 'mtr$case_name$0.f00*' and 'emt$case_name0.f00*' files.

The dumpCFLYpWSS.f file and an example turbChannel.usr file is included on this repo.

'mtr$case_name$0.f00*' files include: 
a. the CFL on GLL points stored in the temperature filed
b. the Y+ values on GLL points of wall elements stored in s1
c. the wall-shear-stress values on GLL points of wall elements stored in s2


'emt$case_name$0.f00*' files include: 
a. the CFL on GLL points stored in the temperature filed
b. the face-averaged Y+ values on 'W  '-faces of the  wall elements stored in s1
c. the wall-shear-stress values on 'W  '-faces  of the wall elements stored in s2


The tutorial is based on the standard turbChannel tutorial.

## LES of a turbulent channel flow.

HiOCFD5 Testcase: WS2 / Resolution Coarse (ID:MS3)
LES of a turbulent channel flow with Re_tau=550

Reference: 
[1] https://how5.cenaero.be/content/ws2-les-plane-channel-ret550 

[2] Myoungkyu Lee and Robert D. Moser,  
Direct numerical simulation of turbulent channel flow up to 
Re_tau = 5200, 2015, Journal of Fluid Mechanics, vol. 774, 
pp. 395-415

Note: 1-D statistics are dumped to 
mean_prof.dat and vel_fluc_prof.dat 
