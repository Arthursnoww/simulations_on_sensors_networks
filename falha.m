t = 0:1:100; 
lambdas = [0.01, 0.05, 0.1]; 

figure;
hold on;
for i = 1:length(lambdas)
    R = exp(-lambdas(i) * t); 
    plot(t, R, 'LineWidth', 2, 'DisplayName', ['\lambda = ' num2str(lambdas(i))]);
end
hold off;
title('Replicação: Confiabilidade do Nó Sensor (Eq. 1)');
xlabel('Tempo (t)');
ylabel('Probabilidade de não-falha R_k(t)');
legend show;
grid on;