function [tabla_resultados] = contraste_lambda_wilks(X_analisis, variables_categoricas, nombre_variable_categorica_intro, nombres_variables_continuas_interes, graficar, nivel_significacion)
nombres_variables_categoricas = categorical(variables_categoricas.Properties.VariableNames);
variable_categorica = variables_categoricas{:, find(nombres_variables_categoricas == char(nombre_variable_categorica_intro))};
categorias_variable_categorica = (categories(variable_categorica));
num_categorias = length(categorias_variable_categorica);
g = num_categorias;
n = size(X_analisis, 1);
p = size(X_analisis, 2);

% Gráfico
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

% Un cell es como una lista, un objeto que puede contener objetos de
% distinto tipo y dimension, entonces creo una lista (cell) vacía y le voy
% añadiendo las submatrices X_i, i = 1, \dots, g
cell_submatrices_muestras = {zeros(g)};
array_vectores_medias_muestras = zeros(1, p);
array_matrices_covarianzas_muestras = zeros(p);
array_tamano_muestral_muestras = zeros(1, g);

% usar cells como listas
for i = 1:g
    % filtramos la submatriz y la asignamos al elemento i del cell (i = 1,
    % ..., g)
    submatriz = X_analisis(find(variable_categorica == categorias_variable_categorica{i,:}), :);
    cell_submatrices_muestras{i} = submatriz;
    
    % Calculamos el vector de medias de la submatriz y lo guardamos en el
    % elemento i-ésimo del array_vectores_medias_muestras
    array_vectores_medias_muestras(:, :, i) = mean(submatriz);

    % Calculamos la matriz de covarianzas de la muestra i = 1, ..., g
    array_matrices_covarianzas_muestras(:, :, i) = cov(submatriz);

    % Obtenemos el tamaño muestral de la muestra i-ésima i = 1, ..., g
    array_tamano_muestral_muestras(i) = size(submatriz, 1);
end

% Obtenemos el vector de medias global y la matriz de covarianzas común
vector_medias_muestrales_global = zeros(1, p);
matriz_covarianzas_muestrales_comun = zeros(p);
for i = 1:g
    vector_medias_muestrales_global = vector_medias_muestrales_global + (array_tamano_muestral_muestras(i) * array_vectores_medias_muestras(:, :, i));
    matriz_covarianzas_muestrales_comun = matriz_covarianzas_muestrales_comun + (array_tamano_muestral_muestras(i) * array_matrices_covarianzas_muestras(:, :, i));
end

vector_medias_muestrales_global = (1/n) * vector_medias_muestrales_global;
matriz_covarianzas_muestrales_comun = (1/(n-g)) * matriz_covarianzas_muestrales_comun;

% Obtenemos las matrices B, W, T
B = zeros(p);
W = (n-g)*matriz_covarianzas_muestrales_comun;
for i = 1:g
    B = B + array_tamano_muestral_muestras(i) * transpose(array_vectores_medias_muestras(:, :, i) - vector_medias_muestrales_global) * (array_vectores_medias_muestras(:, :, i) - vector_medias_muestrales_global) ;
end

% Contraste de hipótesis de lambda Wilks
lambda = det(W)/det(W + B);
a = n-g;
b = g-1;
alpha = a + b - (p+b+1)/2;
beta = sqrt((p^2 * b^2 - 4)/(p^2 + b^2 - 5));
gamma = (p*b - 2)/4;
df_1 = p*b; % grados de libertad numerador F
df_2 = alpha * beta - 2*gamma; % grados libertad denominador F
F_asintotico = (1 - lambda^(1/beta))/lambda^(1/beta) * (alpha * beta - 2*gamma)/(p*b);
F_critico = finv(1-0.05,df_1,df_2);
pvalor = 1 - fcdf(F_asintotico, df_1,df_2); % podemos rechazar la hipótesis nula y suponer que existen diferencias entre las medias

% Presentamos resultados
tabla_resultados = table(lambda, F_asintotico, F_critico, df_1, df_2, pvalor);
end