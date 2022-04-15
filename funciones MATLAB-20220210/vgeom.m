%
% Variabilidad geometrica
%
% La funcion vg=vgeom(D) devuelve la variabilidad geometrica de una matriz D de
% cuadrados de distancias. Se trata de una medida de dispersion de los
% elementos de D.
%
function vg=vgeom(D)
n=size(D,1);
vg=sum(sum(D))/n^2;