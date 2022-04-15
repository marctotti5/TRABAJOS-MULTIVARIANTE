data=load('..\Datos\vinos.txt');
X=data(1:35,:);
group=[ones(20,1); 2*ones(15,1)];
new=data(36,:);
[class,err,POSTERIOR] = classify(new,X,group,'linear')
[class,err,POSTERIOR] = classify(new,X,group,'quadratic')
%
% representacion de los objetos segun el grupo y los nuevos a clasificar
figure
h1 = gscatter(X(:,1),X(:,2),group,'rb','v^',[],'off');
set(h1,'LineWidth',2)
hold on;
plot(new(:,1),new(:,2),'ok','LineWidth',2,'MarkerSize',6);
legend('vino 1','vino 2','nuevo vino','Location','NW')
xlabel('X1')
ylabel('X2')


% representacion de los objetos segun el grupo
%figure
%h1 = gscatter(X(:,1),X(:,2),group,'rb','v^',[],'off');
%set(h1,'LineWidth',2)
%legend('X1','X2','Location','NW')
%
% visualizacion de la clasificacion
[Y1,Y2] = meshgrid(linspace(12,15),linspace(200,1800));
Y1 = Y1(:); Y2 = Y2(:);
[C,err,P,logp,coeff] = classify([Y1 Y2],[X(:,1) X(:,2)],group,'Linear');
hold on;
gscatter(Y1,Y2,C,'rb','.',1,'off');
K = coeff(1,2).const;
L = coeff(1,2).linear; 
% Function to compute K + L*v for multiple vectors
% v=[x;y]. Accepts x and y as scalars or column vectors.
f = @(x,y) K + L(1)*x + L(2)*y;
h2 = fimplicit(f,[12 15 200 1800]);
set(h2,'Color','m','LineWidth',2,'DisplayName','Decision Boundary')
axis([12 15 200 1800])
xlabel('X1')
ylabel('X2')
title('{\bf Linear Classifier; Wines Data}')


% representacion de los objetos segun el grupo
%figure
%h1 = gscatter(X(:,1),X(:,2),group,'rb','v^',[],'off');
%set(h1,'LineWidth',2)
%legend('X1','X2','Location','NW')
%
% representacion de los objetos segun el grupo y los nuevos a clasificar
figure
h1 = gscatter(X(:,1),X(:,2),group,'rb','v^',[],'off');
set(h1,'LineWidth',2)
hold on;
plot(new(:,1),new(:,2),'ok','LineWidth',2,'MarkerSize',6);
legend('vino 1','vino 2','nuevo vino','Location','NW')
xlabel('X1')
ylabel('X2')
%
% visualizacion de la clasificacion
[Y1,Y2] = meshgrid(linspace(12,15),linspace(200,1800));
Y1 = Y1(:); Y2 = Y2(:);
[C,err,P,logp,coeff] = classify([Y1 Y2],[X(:,1) X(:,2)],group,'Quadratic');
hold on;
gscatter(Y1,Y2,C,'rb','.',1,'off');
K = coeff(1,2).const;
L = coeff(1,2).linear; 
Q = coeff(1,2).quadratic;
% Function to compute K + L*v + v'*Q*v for multiple vectors
% v=[x;y]. Accepts x and y as scalars or column vectors.
f = @(x,y) K + L(1)*x + L(2)*y + Q(1,1)*x.*x + (Q(1,2)+Q(2,1))*x.*y + Q(2,2)*y.*y;
h2 = fimplicit(f,[12 15 200 1800]);
set(h2,'Color','m','LineWidth',2,'DisplayName','Decision Boundary')
axis([12 15 200 1800])
xlabel('X1')
ylabel('X2')
title('{\bf Quadratic Classifier; Wines Data}')

