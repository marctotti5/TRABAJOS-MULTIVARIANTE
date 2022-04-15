%
% funcion que calcula el vector de medias y
% las matrices de covarianzas y correlaciones
%
function [m,S,R]=summary(X)
m=mean(X);
S=cov(X,1);
R=corr(X);
end