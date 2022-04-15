%
%  funcion randT2
%
%  Esta funcion genera una muestra de tamaño N de una ley T^2 de
%  Hotelling con p y n grados de libertad.
%
function t=randT2(p,n,N)
%
n=n+1; 
t=zeros(N,1);
for i=1:N
   X=randn(n,p);
   m=mean(X);
   S=cov(X,1);
   t(i,1)=(n-1)*m*inv(S)*m'; % ponemos (n-1)*m*inv(S)*m' y no (n-1)*m'*inv(S)*m, 
   % porque en las matrices de datos cada fila es un vector aleatorio y
   % para no andar trasponiendo datos toodo el rato, lo hacemos
   % directamente
end
histogram(t)
end