% Objetivo: Visualizar o problema da Implosão com LEGENDA CORRETA
clear; clc; close all;

% --- Configuração ---
N = 30;           
Area = 100;       
Raio = 35;        
Fonte_ID = 1;     

% Posições aleatórias
x = rand(1, N) * Area;
y = rand(1, N) * Area;
x(Fonte_ID) = 50; y(Fonte_ID) = 50; % Fonte no centro

% Matriz de Adjacência
Adj = false(N, N);
for i = 1:N
    for j = 1:N
        if i ~= j
            d = sqrt((x(i)-x(j))^2 + (y(i)-y(j))^2);
            if d <= Raio
                Adj(i,j) = true;
            end
        end
    end
end

% --- Preparação Visual ---
figure('Color', 'w');
hold on;
axis([0 Area 0 Area]);
title('Simulação de Flooding: Visualizando a Implosão');

% --- 1. Criar os Objetos da Legenda (Truque para fixar os símbolos) ---
% Plotamos pontos com NaN (Not a Number) para não aparecerem no gráfico,
% mas servirem para criar a entrada correta na legenda.
h_nos      = plot(NaN, NaN, 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 6);
h_ativo    = plot(NaN, NaN, 'o',  'MarkerFaceColor', 'c', 'MarkerSize', 6);
h_fonte    = plot(NaN, NaN, 'p',  'MarkerFaceColor', 'y', 'MarkerSize', 15);
h_seta     = quiver(NaN, NaN, NaN, NaN, 'Color', 'r', 'MaxHeadSize', 0.5, 'AutoScale', 'off'); 
h_implosao = plot(NaN, NaN, 'k:', 'LineWidth', 1.5); 

% Plotamos os nós reais (sem salvar handle para não confundir a legenda depois)
plot(x, y, 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 6);
plot(x(Fonte_ID), y(Fonte_ID), 'p', 'MarkerFaceColor', 'y', 'MarkerSize', 15);

% --- Simulação ---
msgs_enviadas = 0;
nos_que_receberam = false(1, N);
nos_que_receberam(Fonte_ID) = true;
Fila = [Fonte_ID]; 

passos = 0;
while ~isempty(Fila) && passos < N*2
    passos = passos + 1;
    remetente = Fila(1);
    Fila(1) = []; 
    
    vizinhos = find(Adj(remetente, :));
    if isempty(vizinhos), continue; end
    
    for v = vizinhos
        % Seta vermelha (Transmissão)
        quiver(x(remetente), y(remetente), ...
               x(v)-x(remetente), y(v)-y(remetente), ...
               0, 'Color', 'r', 'MaxHeadSize', 0.5, 'LineWidth', 1);
        msgs_enviadas = msgs_enviadas + 1;
        
        if ~nos_que_receberam(v)
            nos_que_receberam(v) = true;
            Fila = [Fila, v]; 
            % Marca como "recebido" (azul ciano)
            plot(x(v), y(v), 'o', 'MarkerFaceColor', 'c', 'MarkerSize', 6); 
        else
            % IMPLOSÃO! Linha pontilhada preta
             plot([x(remetente) x(v)], [y(remetente) y(v)], 'k:', 'LineWidth', 1.5);
        end
    end
    pause(0.2); 
end

% Re-plota a fonte por cima de tudo para garantir visibilidade
plot(x(Fonte_ID), y(Fonte_ID), 'p', 'MarkerFaceColor', 'y', 'MarkerSize', 15);

% --- Legenda Fixada ---
% Agora passamos exatamente os handles que criamos no início
legend([h_nos, h_ativo, h_fonte, h_seta, h_implosao], ...
       {'Nós Iniciais (Verde)', 'Nó Ativo (Ciano)', 'Fonte (Estrela)', 'Transmissão (Seta)', 'Implosão (Linha Pontilhada)'}, ...
       'Location', 'bestoutside');

xlabel(['Total de Mensagens: ' num2str(msgs_enviadas)]);
hold off;