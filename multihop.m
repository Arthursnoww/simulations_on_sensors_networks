D_total = 100; 
n = 4; 

% Caso 1: Transmissão Direta (1 salto grande)
E_direto = D_total^n;

% Caso 2: Multihop (dividir em K saltos)
k_saltos = 1:10; % Testar de 1 a 10 saltos
E_multihop = zeros(1, 10);

for k = 1:10
    d_pequeno = D_total / k; % Distância de cada salto
    % Energia total = k vezes a energia de um salto pequeno
    E_multihop(k) = k * (d_pequeno^n); 
end

figure;
plot(k_saltos, E_multihop, '-o', 'LineWidth', 2);
title('Eficiência Energética: Direto vs. Multihop');
xlabel('Número de Saltos (Hops)');
ylabel('Energia Relativa Total (Proporcional a d^4)');
grid on;