function [X_transformada, negativos_a_positivos, lambda, p_valores] = transformar_boxcox(X, nombres_variables_numericas, plot)
X_transformada = zeros(size(X));
lambda = zeros(size(X_transformada, 2), 1);
minimo_variable = zeros(1, size(X_transformada, 2));
p_valores = zeros(1, size(X_transformada, 2));
negativos_a_positivos = zeros(1, size(X_transformada, 2));
for i = 1:size(X, 2)
    minimo_variable(i) = min(X(:, i));
    variable_desplazada = X(:, i); % en este caso no desplazamos
    negativos_a_positivos(i) = 0;
    if minimo_variable(i) <= 0
        % valor de lambda_2, que hace que la variable sea positiva
        negativos_a_positivos(i) = abs(minimo_variable(i)) + 0.001;
        variable_desplazada = X(:, i) + negativos_a_positivos(i);
    end
    [variable_transformada, lambda(i)] = boxcox(variable_desplazada);
    X_transformada(:, i) = variable_transformada;

    % Realizamos contraste de Kolmogorov-Smirnov-Lilliefors
    [h, p_valores(i)] = lillietest(variable_transformada);
    
    % Graficamos
    if plot == true
        figure
        hist(variable_transformada)
        xlabel(char(nombres_variables_numericas(i))) 
    end
end
end

