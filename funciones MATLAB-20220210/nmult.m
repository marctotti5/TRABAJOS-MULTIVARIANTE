%
% funcion [m,S,X]=nmult(mu,A,n)
%
%    entradas: mu es el vector px1 de medias poblacionales,
%              A  es una matriz cuadrada pxp, de manera que
%                 la matriz de covarianzas poblacionales es
%                 Sigma=A'A,
%              n  es el tamano muestral,
%
%    salidas:  m  es el vector de medias muestrales,
%              S  es la matriz de covarianzas muestrales,
%              X  es la matriz con la muestra generada.
%
function [m,S,X]=nmult(mu,A,n)
% generacion de una muestra p-variante N(0,Id)
p=size(A,2);
Z=randn(n,p);
% generacion de una muestra p-variante N(mu,A'A)
u=ones(n,1);
X=u*mu'+Z*A;
% vector de medias y matriz de covarianzas
m=mean(X);
S=cov(X,1);
end