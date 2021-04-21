# Extract data of x,y,z,u,v,w,p on planes that follow a Chebyshev distribution
## Information
The tool that extracts data and stores them in ASCII files.
This way you avoid having gigantic text files, each slice in y
is stored in a separate file. This becomes important when the 
grids become large.
The routine requires a txt file named INPUT0000
that includes a list of the files you want to post-process.

The name and the format for each output file is:
        XXXXSPECTYYYY
which stores the x,y,z,u,v,w,Pr data of the YYYY plane from
the XXXX file.
e.g.
          0002SPECT0001
includes the data extracted from the 1st y plane (defined by the user)
from the 2nd file inside the INPUT0000 file.
A Chebyshev distribution is used to difine the different y planes.
The Chebyshev distibution has lyp points between BOTTOM_Y and TOP_Y.
A uniform grid is used in the x- and z- direction.
lxp: number of points in x-
lzp: number of points z-
npmax: reduntant for what you are doing.
you also don't need NUMBER_ELEMENTS_X, _Y, _Z.

##LES of a turbulent channel flow.

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
