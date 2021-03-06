%%% Matlab code for "Iterative shifted Chebyshev method for nonlinear stochastic Ito-Volterra integral
%%%equations"
%%% simulation of M=10000 realizations
%%% Example 5.1: X(t)=X_0+a^2\int_0^t \cos(X(s)) \sin^3(X(s)) ds
%%%-a\int_0^t\sin^2(X(s))dW(s),   t\in[0,1]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slg=@(T,n,t) cos(n.*acos((2./T).*t-1));% Shifted Chebyshev polynomials
tic
M=10000;                               %Number of sample paths
T = 1; N0 = 2^12; dt = T/N0;           % size of the time step for sample paths
dW0 = sqrt(dt)*randn(M,N0);            % increments
%%%%%%%%%%%D%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%K%%%%%%%%%%%%%%%%%%%%%%%%
R = 2^4; Dt = R*dt;                    %steps of size Dt = R*dt
N = N0/R;                              % Number of basis functions
N5=N;                                  %Number of collocation points

r=(N5-1:-1:0)';
tt=T/2+T/2*cos(r*pi/(N5-1));           % Shifted chebyshev points

phi=zeros(N5,N);
pphi=zeros(N5,N);

    for j = 1:N
        jj=j-1;
        phi(:,j)=slg(T,jj,tt); 
    end
     A=phi;                        %iteration matrix (equation 3.21)
     pinvA=pinv(A);

j35=0:1:N-1;
for k = 2:N5
    pphi(k,:)=pphi(k-1,:)+(tt(k)-tt(k-1))*slg(T,j35,(tt(k)+tt(k-1))/2);  %the matrix \Phi
end

erend=zeros(M,1);
parfor km = 1:M
    dW=dW0(km,:);
W = cumsum(dW);                    % cumulative sum of the current path
IW=@(t) interp1(0:dt:T,[0,W],t);
WW=IW(tt);                         % linear interpolation of the current path
alpha=zeros(N,1);
betta=zeros(N,1);
appr2=zeros(N5,1);
b1=zeros(N,1);
b2=zeros(N,1);
sai=zeros(N5,N);

%**************************%Example data%***********************

uex=@(t) acot((1/20)*interp1(0:dt:T,[0,W],t)+cot(1/20));
h0=@(t) 1/20;
f0=@(t) 1/400;
g0=@(t) -1/20;
mu=@(x) cos(x).*(sin(x)).^3;
etta=@(x) (sin(x)).^2;
%**********************************************************************
 
 
for k = 2:N5
    sai(k,:)=sai(k-1,:)+phi(k-1,:)*(WW(k)-WW(k-1));%%the matrix \Psi
end
h=h0(tt).*ones(length(tt),1);
f=f0(tt).*ones(length(tt),1);
g=g0(tt).*ones(length(tt),1);

appr1=h+pphi*alpha+sai*betta; %initial guess

cn=0;
alfbet=1;
%%%% system (3.21)__Repeat until the maximum absolute difference between two consecutive
%%%%values of approximation is less than the desired tolerance
      while (alfbet>10^(-16)&&cn<15)
        cn=cn+1;
        b1=f.*mu(appr1);
        alpha=pinvA*b1;
        b2=g.*etta(h+pphi*alpha+sai*betta);
        betta=pinvA*b2;
        appr2=h+pphi*alpha+sai*betta;
       alfbet=max(abs(appr2-appr1));
       appr1=appr2;
      end
uexxend=uex(T);   %The exact solution at the endpoint
erend(km)=abs(uexxend-appr2(end)); % Error of the approximation at the endpoint for current path
end
%%%%%%%%%%%A%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%B%%%%%%%%%%%%%%%%%%%%%%%%
display('mean of errors at endpoint for M paths')
mean(erend)% mean of errors at endpoint for M paths

  toc;

