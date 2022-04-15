function [VT,VG]=MedidasEscalares(X)
S=cov(X,1);
VT=trace(S);
VG=det(S);
end