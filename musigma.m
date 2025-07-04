function [mu, sigma2] = musigma(b,g,n,z)

c0=0.3;  %speed of light in um/fsec
c=c0/n; 
v=1-g;   % <cos(theta)>
w=1-g^2; % <cos(theta^2)> (~0.91)

a=b*v*z;
a2=b*w*z;
a3=(1-exp(-a))/a;

mu=(z/c)*(1-a3);

s1=(w^2-3*w*v)*(exp(-a)-1+a); 
s2=2*(v^2)*(exp(-a2)-1+a2);
s3=(a^2)*w*(w-v);
sigma2=(z/c)^2*(2/3*(s1+s2)/s3 - a3^2);

end

