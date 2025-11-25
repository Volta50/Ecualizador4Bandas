%% Ecualizador de Audio de 4 Bandas - Filtros IIR
% Diseño usando Invariancia del Impulso y Transformación Bilineal
clear all; close all; clc;

%% Parámetros del sistema
Fs = 64000; % Frecuencia de muestreo en Hz
T = 1/Fs; % Período de muestreo

% Frecuencias centrales (Hz)
fc = [102.4, 512, 2560, 12800];

% Cálculo de frecuencias de corte (media geométrica)
f_cutoff = zeros(1,5);
f_cutoff(1) = 0; % Para el primer filtro pasabajos
for i = 2:4
    f_cutoff(i) = sqrt(fc(i-1) * fc(i));
end
f_cutoff(5) = Fs/2; % Para el último filtro pasaaltos

fprintf('Frecuencias de corte:\n');
for i = 1:5
    fprintf('f%d = %.2f Hz\n', i, f_cutoff(i));
end

%% Especificaciones de los filtros analógicos
% Atenuación de 3dB en frecuencias de corte
% Atenuación de 15dB en frecuencias centrales adyacentes

Ap = 3; % Atenuación en banda de paso (dB)
As = 15; % Atenuación en banda eliminada (dB)

%% BANDA 1: Filtro Pasabajos (102.4 Hz)
fprintf('\n=== BANDA 1: Pasabajos (fc = %.1f Hz) ===\n', fc(1));

% Frecuencias normalizadas
wp1 = 2*pi*f_cutoff(2); % Frecuencia de corte
ws1 = 2*pi*fc(2); % Frecuencia de rechazo (512 Hz)

% Diseño del filtro analógico Butterworth
[n1, Wn1] = buttord(wp1, ws1, Ap, As, 's');
[b1_analog, a1_analog] = butter(n1, Wn1, 'low', 's');
fprintf('Orden del filtro: %d\n', n1);

% Método 1: Invariancia del Impulso
[b1_imp, a1_imp] = impinvar(b1_analog, a1_analog, Fs);

% Método 2: Transformación Bilineal
[b1_bil, a1_bil] = bilinear(b1_analog, a1_analog, Fs);

%% BANDA 2: Filtro Pasabanda (512 Hz)
fprintf('\n=== BANDA 2: Pasabanda (fc = %.1f Hz) ===\n', fc(2));

% Frecuencias de diseño
wp2 = 2*pi*[f_cutoff(2) f_cutoff(3)]; % Banda de paso
ws2_lower = 2*pi*fc(1); % Rechazo inferior (102.4 Hz)
ws2_upper = 2*pi*fc(3); % Rechazo superior (2560 Hz)

% Cálculo del orden usando el criterio más restrictivo
[n2a, ~] = buttord(wp2(1), ws2_lower, Ap, As, 's');
[n2b, ~] = buttord(wp2(2), ws2_upper, Ap, As, 's');
n2 = max(n2a, n2b);

% Diseño del filtro analógico pasabanda
[b2_analog, a2_analog] = butter(n2, wp2, 'bandpass', 's');
fprintf('Orden del filtro: %d\n', n2);

% Método 1: Invariancia del Impulso
[b2_imp, a2_imp] = impinvar(b2_analog, a2_analog, Fs);

% Método 2: Transformación Bilineal
[b2_bil, a2_bil] = bilinear(b2_analog, a2_analog, Fs);

%% BANDA 3: Filtro Pasabanda (2560 Hz)
fprintf('\n=== BANDA 3: Pasabanda (fc = %.1f Hz) ===\n', fc(3));

% Frecuencias de diseño
wp3 = 2*pi*[f_cutoff(3) f_cutoff(4)]; % Banda de paso
ws3_lower = 2*pi*fc(2); % Rechazo inferior (512 Hz)
ws3_upper = 2*pi*fc(4); % Rechazo superior (12800 Hz)

% Cálculo del orden
[n3a, ~] = buttord(wp3(1), ws3_lower, Ap, As, 's');
[n3b, ~] = buttord(wp3(2), ws3_upper, Ap, As, 's');
n3 = max(n3a, n3b);

% Diseño del filtro analógico pasabanda
[b3_analog, a3_analog] = butter(n3, wp3, 'bandpass', 's');
fprintf('Orden del filtro: %d\n', n3);

% Método 1: Invariancia del Impulso
[b3_imp, a3_imp] = impinvar(b3_analog, a3_analog, Fs);

% Método 2: Transformación Bilineal
[b3_bil, a3_bil] = bilinear(b3_analog, a3_analog, Fs);

%% BANDA 4: Filtro Pasaaltos/Pasabanda (12800 Hz)
fprintf('\n=== BANDA 4: Filtro (fc = %.1f Hz) ===\n', fc(4));

% Para invariancia del impulso: usar pasabanda
% Para transformación bilineal: usar pasaaltos

% INVARIANCIA DEL IMPULSO - Pasabanda
wp4_pb = 2*pi*[f_cutoff(4) Fs/2.5]; % Banda de paso modificada
ws4_lower = 2*pi*fc(3); % Rechazo (2560 Hz)

[n4_pb, ~] = buttord(wp4_pb(1), ws4_lower, Ap, As, 's');
[b4_pb_analog, a4_pb_analog] = butter(n4_pb, wp4_pb, 'bandpass', 's');
fprintf('Orden del filtro (Inv. Impulso - Pasabanda): %d\n', n4_pb);
[b4_imp, a4_imp] = impinvar(b4_pb_analog, a4_pb_analog, Fs);

% TRANSFORMACIÓN BILINEAL - Pasaaltos
wp4_hp = 2*pi*f_cutoff(4); % Frecuencia de corte
ws4_hp = 2*pi*fc(3); % Frecuencia de rechazo

[n4_hp, Wn4_hp] = buttord(wp4_hp, ws4_hp, Ap, As, 's');
[b4_hp_analog, a4_hp_analog] = butter(n4_hp, Wn4_hp, 'high', 's');
fprintf('Orden del filtro (Bilineal - Pasaaltos): %d\n', n4_hp);
[b4_bil, a4_bil] = bilinear(b4_hp_analog, a4_hp_analog, Fs);

%% Usar el orden mayor para todos los filtros
orden_max = max([n1, n2, n3, max(n4_pb, n4_hp)]);
fprintf('\n=== Orden máximo para uniformidad: %d ===\n', orden_max);

% Rediseño con orden máximo
[b1_analog, a1_analog] = butter(orden_max, Wn1, 'low', 's');
[b1_imp, a1_imp] = impinvar(b1_analog, a1_analog, Fs);
[b1_bil, a1_bil] = bilinear(b1_analog, a1_analog, Fs);

[b2_analog, a2_analog] = butter(orden_max, wp2, 'bandpass', 's');
[b2_imp, a2_imp] = impinvar(b2_analog, a2_analog, Fs);
[b2_bil, a2_bil] = bilinear(b2_analog, a2_analog, Fs);

[b3_analog, a3_analog] = butter(orden_max, wp3, 'bandpass', 's');
[b3_imp, a3_imp] = impinvar(b3_analog, a3_analog, Fs);
[b3_bil, a3_bil] = bilinear(b3_analog, a3_analog, Fs);

[b4_pb_analog, a4_pb_analog] = butter(orden_max, wp4_pb, 'bandpass', 's');
[b4_imp, a4_imp] = impinvar(b4_pb_analog, a4_pb_analog, Fs);

[b4_hp_analog, a4_hp_analog] = butter(orden_max, Wn4_hp, 'high', 's');
[b4_bil, a4_bil] = bilinear(b4_hp_analog, a4_hp_analog, Fs);

%% Comparación de respuestas en frecuencia
figure('Position', [100 100 1400 900]);

for banda = 1:4
    % Seleccionar los coeficientes correspondientes
    switch banda
        case 1
            b_imp = b1_imp; a_imp = a1_imp;
            b_bil = b1_bil; a_bil = a1_bil;
            titulo = sprintf('Banda 1: Pasabajos (fc = %.1f Hz)', fc(1));
        case 2
            b_imp = b2_imp; a_imp = a2_imp;
            b_bil = b2_bil; a_bil = a2_bil;
            titulo = sprintf('Banda 2: Pasabanda (fc = %.1f Hz)', fc(2));
        case 3
            b_imp = b3_imp; a_imp = a3_imp;
            b_bil = b3_bil; a_bil = a3_bil;
            titulo = sprintf('Banda 3: Pasabanda (fc = %.1f Hz)', fc(3));
        case 4
            b_imp = b4_imp; a_imp = a4_imp;
            b_bil = b4_bil; a_bil = a4_bil;
            titulo = sprintf('Banda 4: Pasaaltos/Pasabanda (fc = %.1f Hz)', fc(4));
    end
    
    % Calcular respuestas en frecuencia
    [H_imp, f_imp] = freqz(b_imp, a_imp, 8192, Fs);
    [H_bil, f_bil] = freqz(b_bil, a_bil, 8192, Fs);
    
    % Gráfica
    subplot(2, 2, banda);
    plot(f_imp, 20*log10(abs(H_imp)), 'b-', 'LineWidth', 1.5);
    hold on;
    plot(f_bil, 20*log10(abs(H_bil)), 'r--', 'LineWidth', 1.5);
    
    % Marcar frecuencias importantes
    plot(fc(banda), 0, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
    
    % Añadir líneas de frecuencias de corte y adyacentes
    ylim_vals = [-60 5];
    
    switch banda
        case 1 % Pasabajos
            % Frecuencia de corte (media geométrica)
            plot([f_cutoff(2) f_cutoff(2)], ylim_vals, 'k--', 'LineWidth', 1);
            text(f_cutoff(2), -50, sprintf('%.1f Hz\n(-3dB)', f_cutoff(2)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8);
            % Frecuencia de la banda siguiente (atenuación -15dB)
            plot([fc(2) fc(2)], ylim_vals, 'm--', 'LineWidth', 1);
            text(fc(2), -20, sprintf('%.1f Hz\n(-15dB)', fc(2)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8);
            
        case 2 % Pasabanda (512 Hz)
            % Frecuencia de corte inferior
            plot([f_cutoff(2) f_cutoff(2)], ylim_vals, 'k--', 'LineWidth', 1);
            text(f_cutoff(2), -50, sprintf('%.1f Hz\n(-3dB)', f_cutoff(2)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8);
            % Frecuencia de corte superior
            plot([f_cutoff(3) f_cutoff(3)], ylim_vals, 'k--', 'LineWidth', 1);
            text(f_cutoff(3), -50, sprintf('%.1f Hz\n(-3dB)', f_cutoff(3)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8);
            % Frecuencia banda anterior (atenuación -15dB)
            plot([fc(1) fc(1)], ylim_vals, 'm--', 'LineWidth', 1);
            text(fc(1), -20, sprintf('%.1f Hz\n(-15dB)', fc(1)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8);
            % Frecuencia banda posterior (atenuación -15dB)
            plot([fc(3) fc(3)], ylim_vals, 'm--', 'LineWidth', 1);
            text(fc(3), -20, sprintf('%.1f Hz\n(-15dB)', fc(3)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8);
            
        case 3 % Pasabanda (2560 Hz)
            % Frecuencia de corte inferior
            plot([f_cutoff(3) f_cutoff(3)], ylim_vals, 'k--', 'LineWidth', 1);
            text(f_cutoff(3), -50, sprintf('%.1f Hz\n(-3dB)', f_cutoff(3)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8);
            % Frecuencia de corte superior
            plot([f_cutoff(4) f_cutoff(4)], ylim_vals, 'k--', 'LineWidth', 1);
            text(f_cutoff(4), -50, sprintf('%.1f Hz\n(-3dB)', f_cutoff(4)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8);
            % Frecuencia banda anterior (atenuación -15dB)
            plot([fc(2) fc(2)], ylim_vals, 'm--', 'LineWidth', 1);
            text(fc(2), -20, sprintf('%.1f Hz\n(-15dB)', fc(2)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8);
            % Frecuencia banda posterior (atenuación -15dB)
            plot([fc(4) fc(4)], ylim_vals, 'm--', 'LineWidth', 1);
            text(fc(4), -20, sprintf('%.1f Hz\n(-15dB)', fc(4)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8);
            
        case 4 % Pasaaltos/Pasabanda
            % Frecuencia de corte
            plot([f_cutoff(4) f_cutoff(4)], ylim_vals, 'k--', 'LineWidth', 1);
            text(f_cutoff(4), -50, sprintf('%.1f Hz\n(-3dB)', f_cutoff(4)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8);
            % Frecuencia banda anterior (atenuación -15dB)
            plot([fc(3) fc(3)], ylim_vals, 'm--', 'LineWidth', 1);
            text(fc(3), -20, sprintf('%.1f Hz\n(-15dB)', fc(3)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8);
    end
    
    grid on;
    xlabel('Frecuencia (Hz)');
    ylabel('Magnitud (dB)');
    title(titulo);
    legend('Invariancia del Impulso', 'Transformación Bilineal', ...
           'Frecuencia Central', 'Location', 'best');
    xlim([20 Fs/2]);
    ylim(ylim_vals);
    set(gca, 'XScale', 'log');
end

sgtitle('Comparación de Métodos de Diseño IIR');

%% Análisis de diferencias
fprintf('\n=== ANÁLISIS DE DIFERENCIAS ===\n');
fprintf('1. Invariancia del Impulso:\n');
fprintf('   - Preserva la respuesta en el dominio del tiempo\n');
fprintf('   - Puede presentar aliasing en frecuencias altas\n');
fprintf('   - No es adecuado para filtros pasaaltos (Banda 4 usa pasabanda)\n\n');

fprintf('2. Transformación Bilineal:\n');
fprintf('   - Mapeo no lineal de frecuencias (warping)\n');
fprintf('   - No presenta aliasing\n');
fprintf('   - Permite diseñar filtros pasaaltos directamente\n\n');

%% Ecualizador completo con Transformación Bilineal (recomendado)
fprintf('=== SISTEMA SELECCIONADO: Transformación Bilineal ===\n');

% Función del ecualizador
function y = ecualizador_IIR(x, G1, G2, G3, G4, b1, a1, b2, a2, b3, a3, b4, a4)
    % Filtrar cada banda
    y1 = filter(b1, a1, x) * G1;
    y2 = filter(b2, a2, x) * G2;
    y3 = filter(b3, a3, x) * G3;
    y4 = filter(b4, a4, x) * G4;
    
    % Combinar las señales
    y = y1 + y2 + y3 + y4;
end

%% Ejemplo de uso con señal de prueba
fprintf('\n=== EJEMPLO DE USO ===\n');

% Generar señal de prueba (suma de senoidales)
t = 0:T:1; % 1 segundo
x_test = sin(2*pi*100*t) + sin(2*pi*500*t) + ...
         sin(2*pi*2500*t) + sin(2*pi*10000*t);
x_test = x_test / max(abs(x_test)); % Normalizar

% Ganancias de ejemplo (0 a 2)
G1 = 1.5; % Realzar graves
G2 = 1.0; % Medios sin cambio
G3 = 0.8; % Atenuar medios-agudos
G4 = 1.2; % Realzar agudos

% Aplicar el ecualizador
y_eq = ecualizador_IIR(x_test, G1, G2, G3, G4, ...
                        b1_bil, a1_bil, b2_bil, a2_bil, ...
                        b3_bil, a3_bil, b4_bil, a4_bil);

% Graficar espectros
figure('Position', [100 100 1200 500]);

subplot(1,2,1);
[Pxx, f_psd] = pwelch(x_test, hamming(1024), 512, 2048, Fs);
plot(f_psd, 10*log10(Pxx), 'b-', 'LineWidth', 1.5);
grid on;
xlabel('Frecuencia (Hz)');
ylabel('Potencia (dB/Hz)');
title('Espectro de la Señal Original');
set(gca, 'XScale', 'log');
xlim([50 Fs/2]);

subplot(1,2,2);
[Pyy, f_psd] = pwelch(y_eq, hamming(1024), 512, 2048, Fs);
plot(f_psd, 10*log10(Pyy), 'r-', 'LineWidth', 1.5);
grid on;
xlabel('Frecuencia (Hz)');
ylabel('Potencia (dB/Hz)');
title(sprintf('Espectro Ecualizado (G=[%.1f, %.1f, %.1f, %.1f])', G1, G2, G3, G4));
set(gca, 'XScale', 'log');
xlim([50 Fs/2]);

sgtitle('Comparación Espectral: Original vs Ecualizado');

%% Respuesta global del sistema
figure('Position', [100 100 1000 400]);

% Calcular respuesta combinada
H_total = zeros(size(f_imp));
[H1, f] = freqz(b1_bil, a1_bil, 8192, Fs);
[H2, ~] = freqz(b2_bil, a2_bil, 8192, Fs);
[H3, ~] = freqz(b3_bil, a3_bil, 8192, Fs);
[H4, ~] = freqz(b4_bil, a4_bil, 8192, Fs);

H_total = G1*H1 + G2*H2 + G3*H3 + G4*H4;

plot(f, 20*log10(abs(H_total)), 'k-', 'LineWidth', 2);
hold on;
plot(f, 20*log10(abs(H1)*G1), 'b--', 'LineWidth', 1);
plot(f, 20*log10(abs(H2)*G2), 'g--', 'LineWidth', 1);
plot(f, 20*log10(abs(H3)*G3), 'm--', 'LineWidth', 1);
plot(f, 20*log10(abs(H4)*G4), 'r--', 'LineWidth', 1);

grid on;
xlabel('Frecuencia (Hz)');
ylabel('Magnitud (dB)');
title('Respuesta en Frecuencia del Ecualizador Completo');
legend('Total', 'Banda 1', 'Banda 2', 'Banda 3', 'Banda 4', 'Location', 'best');
set(gca, 'XScale', 'log');
xlim([20 Fs/2]);

fprintf('\nEcualizador diseñado exitosamente.\n');
fprintf('Usar los coeficientes b*_bil y a*_bil para implementación final.\n');