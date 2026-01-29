clear; clc; close all;

% --- Parâmetros ---
Num_Nos = 10;           % Quantidade de sensores
Tempo_Simulacao = 100;  % Tempo total
Duracao_Pacote = 5;     % Quanto tempo leva para enviar uma msg

% --- Cenário 1: CSMA / Acesso Aleatório (Caos) ---
% "Traditional CSMA... repeated collisions" [cite: 277, 280]
% Cada nó escolhe um tempo aleatório para falar
tempos_inicio_csma = randi([1, Tempo_Simulacao - Duracao_Pacote], 1, Num_Nos);
status_csma = zeros(1, Num_Nos); % 0=Sucesso, 1=Colisão

% Detectar Colisões
for i = 1:Num_Nos
    for j = i+1:Num_Nos
        % Verifica se o pacote i se sobrepõe ao pacote j
        inicio_i = tempos_inicio_csma(i);
        fim_i = inicio_i + Duracao_Pacote;
        inicio_j = tempos_inicio_csma(j);
        fim_j = inicio_j + Duracao_Pacote;
        
        if (inicio_i < fim_j) && (inicio_j < fim_i)
            status_csma(i) = 1; % Marcar colisão
            status_csma(j) = 1; % Marcar colisão
        end
    end
end

% --- Cenário 2: TDMA / Agendamento (Ordem) ---
% "Fixed allocation of duplex time slots... Fixed frequency" [cite: 273]
% Cada nó recebe um slot garantido sequencialmente
tempos_inicio_tdma = zeros(1, Num_Nos);
for i = 1:Num_Nos
    % O nó i começa logo depois do nó i-1 terminar (com uma folga pequena)
    tempos_inicio_tdma(i) = (i-1) * (Duracao_Pacote + 1) + 1;
end
% No TDMA ideal, não há colisões (status tudo zero)
status_tdma = zeros(1, Num_Nos); 

% --- Visualização (Gráfico de Gantt de Rede) ---
figure('Color', 'w', 'Position', [100, 100, 800, 600]);

% Subplot 1: CSMA
subplot(2,1,1);
hold on;
title('Protocolo Aleatório (CSMA): Risco de Colisão e Gasto de Energia');
for i = 1:Num_Nos
    x = tempos_inicio_csma(i);
    y = i;
    cor = 'g'; % Verde = Sucesso
    if status_csma(i) == 1
        cor = 'r'; % Vermelho = Colisão (Energia desperdiçada)
    end
    % Desenha o pacote como um retângulo
    rectangle('Position', [x, y-0.4, Duracao_Pacote, 0.8], 'FaceColor', cor);
end
axis([0 Tempo_Simulacao 0 Num_Nos+1]);
ylabel('ID do Nó Sensor');
xlabel('Tempo (ms)');
grid on;

% Subplot 2: TDMA
subplot(2,1,2);
hold on;
title('Protocolo Organizado (TDMA/FDMA): Sem Colisões e Eficiente');
for i = 1:Num_Nos
    x = tempos_inicio_tdma(i);
    y = i;
    % No TDMA é sempre verde (sucesso garantido)
    rectangle('Position', [x, y-0.4, Duracao_Pacote, 0.8], 'FaceColor', 'b');
end
axis([0 Tempo_Simulacao 0 Num_Nos+1]);
ylabel('ID do Nó Sensor');
xlabel('Tempo (ms)');
grid on;

% Legenda Manual
% Criar objetos fantasma para legenda
h_sucesso = plot(NaN, NaN, 's', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k');
h_colisao = plot(NaN, NaN, 's', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
h_tdma    = plot(NaN, NaN, 's', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k');

legend([h_sucesso, h_colisao, h_tdma], ...
       {'Transmissão com Sucesso', 'Colisão (Perda de Dados)', 'Slot TDMA Reservado'}, ...
       'Location', 'best');