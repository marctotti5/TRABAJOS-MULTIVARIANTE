% EIGSORT
%
% Funci�n que ordena los valores propios segun el porcentaje
% de variabilidad explicada (de mayor a menor). Tambi�n se
% reordenan los vectores propios, seg�n los vap's.
% Nota: d es un vector columna.
%
function [v,d]=eigsort(a)
[v,d]=eig(a);
[x,i]=sort(-diag(real(d))); d=-x; v=v(:,i);