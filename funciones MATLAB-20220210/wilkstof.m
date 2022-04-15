%
%  funcion wilkstof
%
%  Esta funcion calcula la aproximacion asintotica de Rao de la
%  distribucion Lambda de Wilks, L(p,a,b), hacia la distribucion
%  F de Fihser-Snedecor, F(m,n).
%
%  [F,m,n]=wilkstof(L,p,a,b)
%
%  entradas: L es el valor de L(p,a,b)
%            p, a, b son los grados de libertad
%
%  salidas:  F es el valor de la F(m,n)
%            m, n son los grados de libertad
%
   function [F,m,n]=wilkstof(L,p,a,b)
   alpha=a+b-(p+b+1)/2;
   beta=sqrt((p^2*b^2-4)/(p^2+b^2-5));
   gamma=(p*b-2)/4;
   m=p*b;
   n=alpha*beta-2*gamma;
%  se redondea n al entero mas proximo
   if n-floor(n)<0.5
      n=floor(n);
   else
      n=floor(n)+1;
   end
   F=(1-L^(1/beta))/(L^(1/beta))*n/m;
   end