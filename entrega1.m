%% Lectura de datos
airbnb_data = readtable('datos_limpios.csv');
airbnb_data.property_type
airbnb_data.Properties.VariableNames % extraer nombres
airbnb_data.Properties.VariableNames{2}


% Separamos variables numéricas y categóricas
variables_numericas = airbnb_data(:, vartype('numeric')) % devuelve variables numéricas de una tabla

% Convertir las variables cell en categoricas
variables_cell = airbnb_data(:, vartype("cell"));
variables_categoricas = array2table(zeros(size(variables_cell)));
variables_categoricas.Properties.VariableNames = variables_cell.Properties.VariableNames;
variables_categoricas = convertvars(variables_cell, variables_categoricas.Properties.VariableNames,'categorical')


%% Análisis exploratorio multivariante
X = table2array(variables_numericas);
nombres_variables_numericas = categorical(variables_numericas.Properties.VariableNames)

%% Variables categóricas
variables_categoricas_array = table2array(variables_categoricas);
nombres_variables_categoricas = categorical(variables_categoricas.Properties.VariableNames)

%% Variables numéricas
% 1. a) 

% Dividimos en variables discretas y continuas
continuas = [1, 3, 4, 9, 16:22];
discretas = setdiff(1:size(X, 2), continuas);

X_continuas = X(:, continuas)
nombres_variables_continuas = nombres_variables_numericas(continuas)
nombres_variables_discretas = nombres_variables_numericas(discretas)
X_discretas = X(:, discretas)

% Ahora trabajaremos solo con variables continuas

% Vector de medias, matriz de covarianzas y correlaciones
m = mean(X_continuas)
S = cov(X_continuas, 1)
R = corr(X_continuas)
plot_map(R, char(nombres_variables_continuas.'))


% Gráfico de dispersión matricial
figure
plotmatrix(X_continuas) % según lo que podemos ver, los datos no parece que sigan una normal multivariante


% 1. b)
% Utilizamos transformaciones de Box-Cox para buscar la normalidad de las
% variables continuas solamente
% las transformaciones de box cox, son sobre datos positivos
[X_continuas_transformada, negativos_a_positivos, lambda, p_valores] = transformar_boxcox(X_continuas, nombres_variables_numericas, false) % para que no se impriman los histogramas

plotmatrix(X_continuas_transformada) % podemos ver que hemos simetrizado los datos 
% ninguna de las variables transformadas es normal

% supondremos normalidad de aquí en adelante

%% Vector de medias, matriz de covarianzas, correlaciones de los datos transformados
% Dividimos en variables discretas y continuas

% Gráfico de dispersión matricial
figure
plotmatrix(X_continuas_transformada)

m_transformada = mean(X_continuas_transformada)
S_transformada = cov(X_continuas_transformada, 1)
R_transformada = corr(X_continuas_transformada)
plot_map(R_transformada, char(nombres_variables_continuas.'))
det(R_transformada)

% 1. c) Obtener medidas escalares de dispersión: variación total, 
% variación generalizada y eta^2 para las variables originales y para las variables transformadas
eta_cuadrado = 1 - det(R) % próximo a 1, es decir, existen relaciones lineales entre variables
varianza_generalizada = det(S)
variacion_total = trace(S)

eta_cuadrado_transformada = 1 - det(R_transformada) % próximo a 1, es decir, existen relaciones lineales entre variables
varianza_generalizada_transformada = det(S_transformada)
variacion_total_transformada = trace(S_transformada)

% hemos disminuido el número de variables y además las hemos transformado
% disminuye el eta_cuadrado, pero no demasiado

%% Barplot de la tabla de frecuencias
tabla_frecuencias_prueba = tabulate(airbnb_data.property_type); % tabla  de frecuencias
t = cell2table(tabla_frecuencias_prueba,'VariableNames', ...
    {'Value','Count','Percent'});
t.Value = categorical(t.Value)
t = sortrows(t, 3, 'descend')
bar(t.Value,t.Count)
hist(airbnb_data.price(airbnb_data.price < 1000))

%% Quitamos datos atípicos - Histograma
q1_price = quantile(airbnb_data.price, 0.25);
q3_price = quantile(airbnb_data.price, 0.75);
iqr_price = iqr(airbnb_data.price);
price_no_atipicos = (airbnb_data.price >= (q1_price - 1.5*iqr_price)) & (airbnb_data.price < q3_price + 1.5*iqr_price);
datos_sin_atipicos = airbnb_data(price_no_atipicos, :);
figure
hist3([datos_sin_atipicos.price, datos_sin_atipicos.bedrooms])

%% Función de densidad multivariante
[pdfx, xi]= ksdensity(datos_sin_atipicos.price);
[pdfy, yi]= ksdensity(datos_sin_atipicos.bedrooms);
% Create 2-d grid of coordinates and function values, suitable for 3-d plotting
[xxi,yyi]     = meshgrid(xi,yi);
[pdfxx,pdfyy] = meshgrid(pdfx,pdfy);
% Calculate combined pdf, under assumption of independence
pdfxy = pdfxx.*pdfyy; 
% Plot the results
figure
mesh(xxi,yyi,pdfxy)
set(gca,'XLim',[min(xi) max(xi)])
set(gca,'YLim',[min(yi) max(yi)])

%% EJERCICIO 2: JORGE
% eliminamos las variables latitud y longitud ya que no tiene sentido
% comparar sus medias
X_analisis = X_continuas_transformada(:,setdiff(1:size(X_continuas_transformada, 2), [2,3]));
nombres_variables_continuas_interes = nombres_variables_continuas(setdiff(1:size(X_continuas_transformada, 2), [2,3]));
nombres_variables_categoricas = categorical(variables_categoricas.Properties.VariableNames);

t2hot_test(X_analisis, variables_categoricas, "host_identity_verified", nombres_variables_continuas_interes, true, 0.05)

%% EJERCICIO 3: MARC
% consideramos todas las transformaciones de variables numéricas, excepto
% las de latitud y longitud, ya que priorizamos poder interpretar los

% Creamos una función que nos da el plotmatrix en funcion de las categorias
% de una variable categorica, y realiza un contraste lambda de wilks entre
% los vectores de medias de las muestras i = 1, ..., g, definidas por las g
% categorias de la variable categorica

contraste_lambda_wilks(X_analisis, variables_categoricas, "property_type", nombres_variables_continuas_interes, true, 0.05)
contraste_lambda_wilks(X_analisis, variables_categoricas, "room_type", nombres_variables_continuas_interes, true, 0.05)
contraste_lambda_wilks(X_analisis, variables_categoricas, "neighbourhood_group_cleansed", nombres_variables_continuas_interes, true, 0.05)

% PCA
[T1,Y1,acum1,T2,Y2,acum2]=comp2()




