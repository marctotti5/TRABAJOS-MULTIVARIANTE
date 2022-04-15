%
% La funcion corr_table=correlaciones(X,Y,pcuant,pnominal) calcula las correlaciones/asociaciones 
% entre las variables originales (columnas de X) y los dos primeros ejes principales de 
% la representacion MDS (dos primeras columnas de Y).
%
% Para las variables cuantitativas se calcula la correlacion de Pearson,
% para las binarias la V de Cramer y para el resto la correlacion de
% Spearman.
%
% Entradas X matriz de datos originales (las columnas deben estar ordenadas como 
%              cuantitativas, nominales, ordinales) 
%          Y matriz de coordenadas principales
%          pcuant numero de variables cuantitativas de X
%          pnominal numero de variables nominales
%
function corr_table=correlaciones(X,Y,pcuant,pnominal)
p=size(X,2); pordinal=p-pcuant-pnominal;
corr_table=zeros(p,3);
% correlaciones con las pcuant variables cuantitativas
corr_table(1:pcuant,:)=corr(Y(:,1:3),X(:,1:pcuant),'type','Pearson')';
% asociaciones con las pnominal variables binarias
for i=pcuant+1:pcuant+pnominal
    corr_table(i,:)=[CramerV(X(:,i),Y(:,1)) CramerV(X(:,i),Y(:,2)) CramerV(X(:,i),Y(:,3))];
end
% correlaciones con las pordinal variables cualitativas (no binarias)
corr_table(pcuant+pnominal+1:p,:)=corr(Y(:,1:3),X(:,pcuant+pnominal+1:p),'type','Spearman')';
