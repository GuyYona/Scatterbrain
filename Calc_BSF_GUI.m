function [out_z, out] = Calc_BSF_GUI(a,b,g,n,NA,fib_radius,aperture_radius,max_z)
%Calculates the transmission attenuation in the entire tissue and along 
% the z-axis according to Beam Spread Function method

% a     absorption constant, [1/um]
% b     scattering constant [1/um]
% g     anisotropy index
% n     refraction index
% NA    of the fiber
% fib_radius     [um]     
% aperture_radius [um],   if 0 then point aperture (dx^2)
%                         if not given (or not positive) then infinite
%                         aperture used (tis_x^2)
% max_z - the maximal tissue thickness [um]
%
% out - the whole tissue volume (optional)
% out_z - the z-axis intensity, through an aperture (aperture_radius)

%% definitions

if exist ('params.mat')
    load params.mat
else load default_params.mat
end

%Reading parameters from file: ANGLE_RES  (32 or 64),
%max_z (default 500)  [um] the maximal tissue thickness,  
%tissue_x (default 1200)  [um]    size of pencil beam ,
%time constant (default 5) [sec] to calculate max_t
%dt (default 5) [fs]

dz = 5;
dx = 5;

c = 0.3/n;    % speed of light in medium, [um/fsec]

tis_x = ceil(1001/dx);        % width of final tissue [dx*um]
tis_z = max_z/dz;         % depth of final tissue [dz*um]
 
x=-tissue_x/2:dx:tissue_x/2; 
y=x; 
z= dz:dz:(tis_z*dz+1);    %[um]

[mu, sigma2] = musigma(b, g, n, max(z));
max_t = (time_p)*sigma2/mu;   
tau=0:dt:max_t;    

NA = NA/n;            

if ~exist('fib_radius','var')
    fib_radius = -1;
end
fib_radius = fib_radius/dx;

%% create BSF

BSF = zeros(length(x), length(x), length(z)); 

bar = waitbar(0,'Calculating pencil beam...');
for k=1:length(z)
       waitbar(k / length(z), bar);     
       BSF(:,:,k) = BSF_6D_sum_s_v3(x,y,z(k),tau+z(k)/c,a,b,g,n); 
end

close(bar);

[x,y,z] = size(BSF);

%%  Adds unscattered (ballistic) photons

BSF = cat(3,zeros(x,y),BSF);           % adds zeros for z=0;
BSF_bal = zeros(x,y,z+1);

for k=1:(z+1)
     BSF_bal(ceil(x/2),ceil(x/2),k) = exp(-(b+a)*(k-1)*dz);
     BSF(:,:,k) = BSF(:,:,k)*(1-exp(-b*(k-1)*dz)) + BSF_bal(:,:,k);          
end

clear BSF_bal;

%% More definitions

tissue = zeros(tis_x, tis_x, tis_z);

n_phi = ANGLE_RES+1;
phi = linspace(0,2*pi, n_phi);
theta = 0;

n_psi = ANGLE_RES;
psi = linspace(0, asin(NA), n_psi);


%% create translation transformations

axis_trans = [1     0   0  0;          % translation matrix to rotate along the center. 
              0     1   0  0;
              0     0   1  0;
              -x/2 -x/2 0  1];
     
mid_trans =  [1     0     0  0;     % translation matrix. 
              0     1     0  0;     %  moves result to center of destination
              0     0     1  0;    
              tis_x/2 tis_x/2 0  1];
        
%% create rotation transformations

Q = 1/(n_phi-1);   

%a_weight = exp(-psi.^2/((2*asin(NA))^2));     % to use for gaussian angular distribution
                                                % in this case also change psi limits
a_weight = ones(1,length(psi));

h = waitbar(0,'Calculating angular convolution...');
for i=1:(n_phi-1)
    waitbar(i/n_phi);
    
    [ux, uy, uz] = sph2cart(phi(i), theta, 1);        % rotation axis
    
    for j=1:(n_psi-1)

        p = (psi(j) + psi(j+1))/2;
        
        R = [cos(p)+ux^2*(1-cos(p))      ux*uy*(1-cos(p))-uz*sin(p)  ux*uz*(1-cos(p))+uy*sin(p) 0;
             ux*uy*(1-cos(p))+uz*sin(p)  cos(p)+uy^2*(1-cos(p))      uy*uz*(1-cos(p))-ux*sin(p) 0;
             ux*uz*(1-cos(p))-uy*sin(p)  uy*uz*(1-cos(p))+ux*sin(p)  cos(p)+uz^2*(1-cos(p))     0;
             0                           0                           0                          1]; 

        T = affine3d(axis_trans*R*mid_trans);
        J = imwarp(BSF,T,'outputview',imref3d([tis_x tis_x tis_z]));

        %tissue = tissue + a_weight(j)*Q*(cos(p)-cos(psi(j+1)))/(1-cos(asin(NA)))*J;     % see documentation       
        tissue = tissue + a_weight(j)*Q*(sin(p))/(1-cos(asin(NA)))*J;     % see documentation       
    end
end
close(h);

%% creating disk pattern and convolution

if (nargin > 5)&&(fib_radius > 0)
    pattern_length = 2*ceil(fib_radius)+1;
    %s_weight = exp(-(1:pattern_length).^2/(fib_radius^2));
    D = zeros(pattern_length,pattern_length);
    for i=1:pattern_length
        for j=1:pattern_length
            radius_sq = ((i-ceil(pattern_length/2))^2+(j-ceil(pattern_length/2))^2);
            if fib_radius^2 >= radius_sq
                D(i,j) = 1;
                %D(i,j) = s_weight(round(sqrt(radius_sq))+1);
            end
        end
    end
    D = D/sum(sum(D)); 
    tissue = convn(tissue,D); 
else
    aperture_radius = -1;
end

[tis_x, tis_y, tis_z] = size(tissue);


%% output

if nargout == 2
    out = tissue;
end

%% Collecting light over an aperture
if aperture_radius == 0     % no aperture
    all_max = tissue(ceil(tis_x/2), ceil(tis_x/2), 1);
    out_z = squeeze(tissue(ceil(tis_x/2),ceil(tis_x/2),:))/all_max;
    
else
    
    radius = aperture_radius / dx;
    intensity = zeros(tis_z,1);     % initialization
    
    for k=1:tis_z    
        if aperture_radius == -1      % infinite aperture
            intensity(k) = sum(sum(squeeze(tissue(:,:,k))));
        else
            for i=1:tis_x
                for j=1:tis_x
                    if radius^2 >= ((i-ceil(tis_x/2))^2+(j-ceil(tis_x/2))^2)
                        intensity(k) = intensity(k) + tissue(i,j,k);
                    end
                end
            end
        end
    end
    
    out_z = intensity/intensity(1);   % normalization
end

assignin ('base', 'dx', dx); 
assignin ('base', 'dz', dz);
assignin ('base', 'tis_x', tis_x);
assignin ('base', 'tis_y', tis_y);
assignin ('base', 'tis_z', tis_z);
