% Script: Simulacao_SPIN_Solucao.m
% Objetivo: Simular o protocolo SPIN (ADV -> REQ -> DATA) como solução ao Flooding
% Baseado na seção "SENSOR PROTOCOLS FOR INFORMATION VIA NEGOTIATION" 

clear; clc; close all;

% --- Parâmetros ---
N = 15;
Area = 100;
Raio = 40;
Fonte_ID = 1;

% Custos de Energia (Arbitrários para comparação)
Custo_DATA = 100; % Enviar o dado é caro (ex: imagem, audio)
Custo_Meta = 5;   % ADV e REQ são metadados pequenos e baratos

% --- Configuração da Rede ---
x = rand(1, N) * Area;
y = rand(1, N) * Area;
x(Fonte_ID) = 50; y(Fonte_ID) = 50; % Fonte no centro

% Calcular Vizinhos
Adj = false(1, N);
for i = 2:N
    d = sqrt((x(i)-x(1))^2 + (y(i)-y(1))^2);
    if d <= Raio
        Adj(i) = true;
    end
end
vizinhos = find(Adj);

% --- Cenário: Alguns vizinhos já têm o dado (Redundância) ---
% No Flooding, eles receberiam de novo (desperdício).
% No SPIN, eles vão ignorar o ADV.
tem_o_dado = false(1, N);
% Vamos dizer que 40% dos vizinhos já possuem essa informação de outra rota
num_vizinhos = length(vizinhos);
num_redundantes = floor(num_vizinhos * 0.4); 
if num_redundantes > 0
    vizinhos_redundantes = vizinhos(randperm(num_vizinhos, num_redundantes));
    tem_o_dado(vizinhos_redundantes) = true;
end

% --- Visualização ---
figure('Color', 'w', 'Position', [100, 100, 900, 600]);
subplot(1, 2, 1); % Lado esquerdo: Mapa
hold on; axis([0 Area 0 Area]); axis square;
title('Protocolo SPIN: Negociação (ADV-REQ-DATA)');

% Desenhar nós
h_nos = plot(x, y, 'ko', 'MarkerFaceColor', 'w', 'MarkerSize', 8);
% Destacar Fonte
h_fonte = plot(x(Fonte_ID), y(Fonte_ID), 'p', 'MarkerFaceColor', 'y', 'MarkerSize', 15);
% Destacar quem já tem o dado (não precisa receber de novo)
h_tem = plot(x(tem_o_dado), y(tem_o_dado), 'ko', 'MarkerFaceColor', 'c', 'MarkerSize', 8);

% --- FASE 1: ADV (Anúncio) ---
% Fonte envia metadados baratos para todos os vizinhos
% [cite: 506] "broadcasts an ADV message containing a descriptor"
pause(1);
title('FASE 1: ADV (Anúncio) - "Eu tenho dados!"');
for v = vizinhos
    quiver(x(Fonte_ID), y(Fonte_ID), x(v)-x(Fonte_ID), y(v)-y(Fonte_ID), ...
        0, 'Color', 'b', 'LineStyle', '--', 'MaxHeadSize', 0.5);
end
% Legenda Fase 1
text(5, 5, 'Setas Azuis: ADV (Barato)', 'Color', 'b');
pause(2);

% --- FASE 2: REQ (Requisição) ---
% Apenas quem NÃO tem o dado pede
% [cite: 507] "If a neighbor is interested... sends a REQ"
title('FASE 2: REQ (Requisição) - "Eu quero!"');
quem_pediu = [];
for v = vizinhos
    if ~tem_o_dado(v)
        % Envia REQ de volta para a fonte
        quiver(x(v), y(v), x(Fonte_ID)-x(v), y(Fonte_ID)-y(v), ...
            0, 'Color', 'g', 'LineWidth', 1.5, 'MaxHeadSize', 0.5);
        quem_pediu = [quem_pediu, v];
    else
        % Desenha um X vermelho em quem ignorou
        plot(x(v), y(v), 'rx', 'MarkerSize', 12, 'LineWidth', 2);
    end
end
text(5, 10, 'Setas Verdes: REQ', 'Color', 'g');
text(5, 15, 'X: Ignorou (Economia)', 'Color', 'r');
pause(2);

% --- FASE 3: DATA (Envio Real) ---
% Fonte envia o dado pesado SÓ para quem pediu
% [cite: 510] "DATA is sent to this neighbor"
title('FASE 3: DATA - Envio seletivo');
for v = quem_pediu
    quiver(x(Fonte_ID), y(Fonte_ID), x(v)-x(Fonte_ID), y(v)-y(Fonte_ID), ...
        0, 'Color', 'r', 'LineWidth', 2, 'MaxHeadSize', 0.5);
end
text(5, 20, 'Setas Vermelhas: DADOS (Caro)', 'Color', 'r');

legend([h_fonte, h_tem], {'Fonte', 'Vizinho que já tinha o dado'}, 'Location', 'southoutside');

% --- CÁLCULO DE ECONOMIA (Gráfico de Barras) ---
subplot(1, 2, 2); % Lado direito: Gráfico
num_total_vizinhos = length(vizinhos);
num_interessados = length(quem_pediu);

% Custo Flooding: Envia DATA para TODOS (cegamente)
gasto_flooding = num_total_vizinhos * Custo_DATA;

% Custo SPIN: (ADV p/ todos) + (REQ dos interessados) + (DATA p/ interessados)
gasto_spin = (num_total_vizinhos * Custo_Meta) + ...
             (num_interessados * Custo_Meta) + ...
             (num_interessados * Custo_DATA);

bar([gasto_flooding, gasto_spin]);
set(gca, 'XTickLabel', {'Flooding', 'SPIN'});
ylabel('Unidades de Energia Gastas');
title(['Comparação de Custo (Economia: ' num2str(100 - (gasto_spin/gasto_flooding)*100, '%0.1f') '%)']);
grid on;

% Cores nas barras
h_bar = findobj(gca,'Type','bar');
h_bar.FaceColor = 'flat';
h_bar.CData(1,:) = [1 0 0]; % Flooding Vermelho
h_bar.CData(2,:) = [0 0.5 0]; % SPIN Verde