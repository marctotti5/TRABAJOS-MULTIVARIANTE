% JACCARD
%
% Dada una matriz de datos binarios X (n,p), la funcion S=jaccard(X) devuelve
% la matriz de similaridades, segun el coeficiente de similaridad de Jaccard,
% entre los n individuos.
%
%
 function S=jaccard(X)
 [n,p]=size(X);
 J=ones(n,p);
 a=X*X';
 d=(J-X)*(J-X)';
 % para eliminar posibles ceros en el denominador
 [i0,j0]=find(d==p);
 for i=1:length(i0)
     d(i0(i),j0(i))=p-1;
 end    
 S=a./(p*ones(n)-d);
 