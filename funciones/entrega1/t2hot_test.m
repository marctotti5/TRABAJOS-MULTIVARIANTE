function [tabla_resultados] = t2hot_test(X_analisis, variables_categoricas, nombre_variable_categorica_intro, nombres_variables_continuas_interes, graficar, alpha)
nombres_variables_categoricas = categorical(variables_categoricas.Properties.VariableNames);
variable_categorica = variables_categoricas{:, find(nombres_variables_categoricas == char(nombre_variable_categorica_intro))};
categoria1 = find(variable_categorica=='true');
categoria2 = find(variable_categorica=='false');

datos_T = X_analisis(categoria1,:);
datos_F = X_analisis(categoria2,:);

n1 = size(datos_T,1);
n2 = size(datos_F,1);
p = size(datos_T,2);

if graficar == true
    group = variable_categorica; 
    color = lines(length(categories(group))); % color = lines(length(categories(variables_categoricas{:, j})))
    xnames = char(nombres_variables_continuas_interes); %nombres_variables_numericas_transformadas
    figure
    gplotmatrix(X_analisis,[],group,color,[],[],[],'grpbars',xnames)
    title(strcat('Variables numéricas transformadas por'," ", char(nombre_variable_categorica_intro)),'fontsize',14);
    [h,icons] = legend('FontSize',12);
    set(icons,'MarkerSize',12);
end

xbar = (1/n1)*datos_T'*ones(n1,1);
ybar = (1/n2)*datos_F'*ones(n2,1);

Sp = (1/(n1+n2))*(n1*cov(datos_T) + n2*cov(datos_F));

T2 = (n1*n2/(n1+n2))*(xbar - ybar)'*inv(Sp)*(xbar - ybar);
n = n1 + n2 - 2;

F_exp = (n-p+1)/(n*p)*T2;

F_critico = finv(1-alpha, p,n-p+1);
pvalor = 1 - fcdf(F_exp, p,n-p+1);

% Tabla resultados
tabla_resultados = table(T2, F_exp, F_critico,pvalor);


end