function lambda=boxcoxn(x)
[m,n]=size(x);
lambda_ini=zeros(n,1);
for ii=1:n
    [temp,lambda_ini(ii,1)]=boxcox(x(:,ii));
end
fun=@(lambda)(log(det((cov(((x.^repmat(lambda',m,1)-1)./repmat(lambda',m,1))))))*m/2-(lambda-1)'*(sum(log(x)))');
lambda=fminsearch(fun,lambda_ini);
end