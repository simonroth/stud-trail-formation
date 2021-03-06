function [] = initial( D0, I0, g, a0, a, T, dt, backup, simfolder, import, export, geofile, popfile, growfile )
%INITIAL prepars all the input data for the simulation.
%   All parameters and constants and all input data are converted and
%   prepared to run the simulation.


	% folder structure
	simpath = initial_structure( backup, simfolder, export );


	%load input data
	[ geo, pop, grow ] = initial_load( backup, import, geofile, popfile, growfile, simpath );


	% get dimension of geodata
	[ Y, X ] = size( geo );


	% get indices of nodes
	nodes = find( geo == 3 );


	% get pulses
	I = initial_pulse( I0, a0, a, pop, grow, nodes );


	% define von Neumann neighbourhood (x y)
	neigh = [         0 -1;
		      -1  0;         1  0;
			          0  1       ];


	% initialize conductivity and path
	D    = zeros( X*Y, X*Y );
	path = geo;
	
	[ D, path, t0 ] = initial_dpath( dt, backup, D0, simpath, geo, Y, X, neigh, D, path );


	% initialize flux
	flux = zeros( X*Y, X*Y );


	% export data for backup
	if ( backup ~= 1 )

		save( [ simpath, 'geodata' ], 'geo' );
		save( [ simpath, 'population' ], 'pop' );
		save( [ simpath, 'growth' ], 'grow' );

	end


	% start main loop
	loop( g, a0, a, T, dt, geo, simpath, Y, X, nodes, I, neigh, D, path, t0, flux );


end


%% create folder structure
function [ simpath ] = initial_structure( backup, simfolder, export )


	if ( backup == 1 )

		%folder path
		simpath = [ export, simfolder ];

	else

		%get unique foldername
		foldername = int2str( now*10^5 );

		%create folders
		mkdir( [ export, foldername ] );
		mkdir( [ export, foldername, '/conductivity' ] );
		mkdir( [ export, foldername, '/path' ] );

		%folder path
		simpath = [ export, foldername, '/' ];

	end


end


%% load input data
function [ geo, pop, grow ] = initial_load( backup, import, geofile, popfile, growfile, simpath )


	if ( backup == 1 )

		% load exported files
		load( [ simpath, 'geodata.mat' ] );
		load( [ simpath, 'population.mat' ] );
		load( [ simpath, 'growth.mat' ] );

	else

		% load input files
		geo  = load( [ import , geofile ] );
		pop  = load( [ import, popfile ] );
		grow = load( [ import, growfile ] );

	end


end


%% initialize pulses
function [ I ] = initial_pulse( I0, a0, a, pop, grow, nodes )


	% initial pulses with mean of flux interval
	I = ones( length( nodes ), 1 )*( ( I0( 1 )+I0( 2 ) )/2 );

	% compute pulses for population growth
	if ( a > a0 )

		for i = 1:length( nodes )

			% assume a linear growth
			I( i ) = pop( nodes( i ) )*( 1+grow( nodes( i ) )/100 )^( a-a0 );

		end
		
		% compute linear function of fluxes in interval
		a = ( I0( 2 )-I0( 1 ) )/( max( I )-min( I ) );
		b = 1 - ( I0( 2 )-I0( 1 ) )/( max( I )-min( I ) )*min( I );

		% final flux matrix
		I = a*I+b;
		
	end


end


%% initialize conductivity and path
function [ D, path, t0 ] = initial_dpath( dt, backup, D0, simpath, geo, Y, X, neigh, D, path )


	% initial starttime
	t0 = 0;

	if ( backup == 1 )

		%get all saved conductivities
		backupD = dir( [ simpath, 'conductivity_*.mat' ] );
		
		%get last conductivity
		lastD = backupD( length( backupD ) ).name;

		%load last conductivity
		load( [ simpath, lastD ] );

		%get last timestep
		t0 = sscanf( lastD, 'conductivity_%i.mat' )*dt+dt;

	end

	% initialize or restore conductivity matrix
	for i = 1:X
		for j = 1:Y

			for k = 1:length( neigh )

				m = i+neigh( k, 1 );
				n = j+neigh( k, 2 );

				if ( geo( j, i ) > 0 && m >= 1 && n >= 1 && m <= X && n <= Y && geo( n, m ) > 0 )

					p = varnum( n, m, Y );
					q = varnum( j, i, Y );

					if ( backup ~= 1 )

						D( p, q ) = D0;

					end

					if ( geo( p ) ~= 3 && D( p, q ) > eps )

						path( p ) = 2;

					end

				end

			end

		end
	end


end