clear; clc; close all;

% --- Parâmetros ---
N = 50;           % Número de nós (Densidade alta)
Area = 100;       % Tamanho da área (100x100m)
Raio = 25;        % Raio de comunicação dos sensores

x = rand(1, N) * Area;
y = rand(1, N) * Area;

% --- Visualização ---
figure('Color', 'w');
hold on;

% Desenhar conexões (Quem ouve quem?)
num_conexoes = 0;
for i = 1:N
    for j = i+1:N
        dist = sqrt((x(i)-x(j))^2 + (y(i)-y(j))^2);
        if dist <= Raio
            % Desenha uma linha cinza clara entre vizinhos
            plot([x(i) x(j)], [y(i) y(j)], 'Color', [0.8 0.8 0.8]);
            num_conexoes = num_conexoes + 1;
        end
    end
end

% Desenhar os nós
plot(x, y, 'ko', 'MarkerFaceColor', 'b', 'MarkerSize', 6);

% Estética
title(['Topologia de Rede de Sensores (N=', num2str(N), ', R=', num2str(Raio), 'm)']);
xlabel('Posição X (m)');
ylabel('Posição Y (m)');
axis square;
grid on;
box on;

text(5, -10, ['Total de Conexões: ' num2str(num_conexoes)], 'FontSize', 10);
hold off;