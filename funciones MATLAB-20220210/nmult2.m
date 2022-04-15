%
% funcion [m,S,R,X]=nmult2(mu,Sigma,n)
%
%    entradas: mu es el vector px1 de medias poblacionales,
%              Sigma es la matriz pxp de covarianzas poblacionales,
%              n  es el tamano muestral,
%
%    salidas:  m  es el vector de medias muestrales,
%              S  es la matriz de covarianzas muestrales,
%              R es la matriz de correlaciones,
%              X es la muestra generada.
%
function [m,S,R,X]=nmult2(mu,Sigma,n)
A=chol(Sigma);
% generacion de una muestra p-variante N(0,Id)
[p,p]=size(A);
Z=randn(n,p);
% generacion de una muestra p-variante N(mu,A'A)
u=ones(n,1);
X=u*mu'+Z*A;
% vector de medias y matriz de covarianzas
m=mean(X);
S=cov(X,1);
R=corrcoef(X);