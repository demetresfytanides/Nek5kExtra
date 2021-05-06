# An informal introduction to neknek

The 3D periodic hill example is modified to be solved as:
1. a mono-domain/1-session nek5000 simulaiton
2. a 2-domain/2-session neknek simulation

##Workflow & files needed for a mono-domain/ single session NEK5000 simulation

i. files:
a. 1  SIZE file
b. 1 *box file (optional. used in case genbox is used for the grid generation)
c. 1 *.rea (or *.par) file
d. 1 *.map (or *.ma2) file
e. 1 *.re2 (optional for large problems) file
f. 1 *.usr file

ii. steps:
generate rea or re2 using genbox
a. >genbox
  (…)
b. generate map files using genmap
>genmap  (…)
c. compile the code
>makenek case_name(*.usr)
d. run the code
>nekmpi case_name np

##Workflow & files needed for a 2-domain/ 2-session NEKNEK simulation

i. files:
a. 1  SIZE file
b. 2 *box files (optional. used in case genbox is used for the grid generation)
c. 2 *.rea (or *.par) file
d. 2 *.map (or *.ma2) file
e. 2 *.re2 (optional for large problems) file
f. 1 *.usr file

ii. steps:
a. generate rea or re2 using genbox for each domain
>genbox
  (…) 1st domainA
>genbox
  (…) 2nd domainB
b. generate map files using genmap dor each domain
>genma  (…) 1st domainA
>genmap  (…) 2nd domainB
c. compile the code
>makenek case_name(*.usr)
d. run the code
>neknek domainA domainB np np



## 3D periodic hill example (mono-domain)

This example is similar to the one presented in Nek5000 documentation, however
the hill profile is consistent with Almeida et al. 1993 and described at
https://turbmodels.larc.nasa.gov/Other_LES_Data/2Dhill_periodic/hill-geometry.dat

HOW TO RUN THE CASE
1. Compile the code
2. Build the initial box mesh using genbox and phill.box -> box.re2
3. cp box.re2 phill.re2
4. genmap on phill.re2
5. Check phill.par and run the simulation
5. The mesh of the periodic hill is saved as newre2.re2

REMARKS:
- phill.re2 is a rectangular channel
- the geometric parameters of the hill are defined in userdat2
- it is assumed that the Reynolds number is based on the average velocity
  over the inlet plane


## 3D periodic hill example (2-domain)
HOW TO RUN THE CASE
1. Compile the code
2. Build the initial box mesh using genbox and lower.box -> box.re2
3. cp box.re2 lower.re2
4. Build the initial box mesh using genbox and upper.box -> box.re2 
5. cp box.re2 upper.re2
6. genmap on lower.re2
7. genmap on upper.re2
8. Check lower.par and upper.par
9. Run the simulation neknek lower upper 4 4




## References
[1] MITTAL, K., DUTTA, S., & FISCHER, P. (2019). Nonconforming Schwarz-spectral element methods for incompressible flow. Computers & Fluids, 191, 104237.

[2] MITTAL, K., DUTTA, S., & FISCHER, P. (2021). Multirate timestepping for the incompressible Navier-Stokes equations in overlapping grids. Journal of Computational Physics, 437, 110335.

[3] MITTAL, K. (2019). Highly scalable solution of incompressible Navier-Stokes equations using the spectral element method with overlapping grids. University of Illinois at Urbana-Champaign.


