% Modeling and Simulating Social Systems with MATLAB
% http://www.soms.ethz.ch/matlab
% Author: Gabriela Schaer, Simon Roth, Lucas Boettcher 2012
% http://github.org/Trail-Formation


clear


% parameters and constants
%--------------------------------------------------------------------------

D0 =   1.00;	%initial conductivity
I0 = [ 1; 3 ];	%flux interval
g  =   1.80;	%expans equation gamma
a0 =   2011;	%year of simulation data
a  =   2050;	%year of simulation, no growth for a < a0

T  = 1000;		%end of simulation
dt = 0.01;		%timestep of simulation


% backup simulation
%--------------------------------------------------------------------------

backup    = 0;				%1 for TRUE, 0 for FALSE
simfolder = '';				%folder of simulation to backup (with slash /)


% folder sturcture
%--------------------------------------------------------------------------

import = 'input/';		%folder of input data
export = 'output/';		%folder to save the simulation results


% input data
%--------------------------------------------------------------------------

geofile  = 'geodata.txt';		%coded geodata
popfile  = 'population.txt';	%population
growfile = 'growth.txt';		%population growth in percent


% initialize simulation
%--------------------------------------------------------------------------

initial( D0, I0, g, a0, a, T, dt, backup, simfolder, import, export, geofile, popfile, growfile );