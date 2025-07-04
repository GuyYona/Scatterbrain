function K=BSF_6D_sum_s_v3(x,y,z,t,a,b,g,n)

% g  anisotropy factor
% n - refraction index of tissue

c0=0.3; %velocity of light in um/fsec
c=c0/n; 

dt = t(2)-t(1);

% definitions
[miu, sigma2] = musigma(b,g,n,z);

g1=miu^2/sigma2;  
g2=miu/(sigma2*gamma(g1)); 

%% creating the BSF

K_sum_t=zeros(length(x),length(y));

K_origin=K_sum_t;

for i=1:length(x)
    for j=1:length(y)
        ro=[x(i);y(j)];
        K_origin(i,j) = (ro.'*ro);   
    end      
end


for m=2:length(t)
    tau=t(m)-z/c;

    g3=miu*tau/sigma2;

    if g3>5
        break;      %this ensures most of the energy remains in the calculation.
    end

    G=g2*(g3^(g1-1))*exp(-g3);         

    H = 3./(4*pi*c*tau*z).*exp(-3*K_origin./(4*tau*c*z));
    
    K = H.*G*(exp(-a*(z+c*tau)));
    
    K_sum_t = K_sum_t + K*dt;

end

               
K=squeeze(K_sum_t);

end

