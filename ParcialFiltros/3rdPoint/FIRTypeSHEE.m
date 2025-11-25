%% Ecualizador de Audio de 4 Bandas - Filtros FIR
% Diseño usando Ventanas con fir1()
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

%% Especificaciones de los filtros FIR
% Para filtros FIR: Atenuación límite en banda de paso = 6dB
% Atenuación en banda eliminada = 15dB

Ap = 6; % Atenuación en banda de paso (dB) - específico para FIR
As = 15; % Atenuación en banda eliminada (dB)

%% Selección de ventana según especificaciones
% Análisis de ventanas disponibles:
% - Rectangular: As ≈ 21 dB, Δf = 0.9/N
% - Hann: As ≈ 44 dB, Δf = 3.1/N
% - Hamming: As ≈ 53 dB, Δf = 3.3/N
% - Blackman: As ≈ 74 dB, Δf = 5.5/N
% - Kaiser: As ajustable mediante β

% Con As = 15 dB requerido, la ventana RECTANGULAR es suficiente
% Sin embargo, usaremos HAMMING para mejor comportamiento

fprintf('\n=== SELECCIÓN DE VENTANA ===\n');
fprintf('Atenuación requerida en banda eliminada: %.1f dB\n', As);
fprintf('Ventana seleccionada: HAMMING (As ≈ 53 dB)\n');
fprintf('Atenuación en banda de paso (FIR): %.1f dB\n', Ap);

%% Función para calcular orden del filtro
function N = calcular_orden_fir(fp, fs, Fs, ventana)
    % fp: frecuencia de paso
    % fs: frecuencia de rechazo
    % Fs: frecuencia de muestreo
    % ventana: tipo de ventana
    
    df = abs(fs - fp); % Ancho de banda de transición
    df_norm = df / Fs; % Normalizado
    
    switch ventana
        case 'rectangular'
            factor = 0.9;
        case 'hann'
            factor = 3.1;
        case 'hamming'
            factor = 3.3;
        case 'blackman'
            factor = 5.5;
        otherwise
            factor = 3.3; % Por defecto Hamming
    end
    
    N = ceil(factor / df_norm);
    
    % Asegurar que N es par para filtros tipo I (simetría)
    if mod(N, 2) == 1
        N = N + 1;
    end
end

ventana_tipo = 'hamming';

%% BANDA 1: Filtro Pasabajos (102.4 Hz)
fprintf('\n=== BANDA 1: Pasabajos (fc = %.1f Hz) ===\n', fc(1));

% Frecuencias de diseño
fp1 = f_cutoff(2); % Frecuencia de paso (228 Hz)
fs1 = fc(2); % Frecuencia de rechazo (512 Hz)

% Calcular orden del filtro
N1 = calcular_orden_fir(fp1, fs1, Fs, ventana_tipo);
fprintf('Orden del filtro: %d\n', N1);
fprintf('Ancho de transición: %.2f Hz\n', fs1 - fp1);

% Diseño del filtro FIR pasabajos
% Frecuencia normalizada (0 a 1, donde 1 es Nyquist)
Wn1 = f_cutoff(2) / (Fs/2);
b1_fir = fir1(N1, Wn1, 'low', hamming(N1+1));

%% BANDA 2: Filtro Pasabanda (512 Hz)
fprintf('\n=== BANDA 2: Pasabanda (fc = %.1f Hz) ===\n', fc(2));

% Frecuencias de diseño
fp2_low = f_cutoff(2); % Frecuencia de paso inferior (228 Hz)
fs2_low = fc(1); % Frecuencia de rechazo inferior (102.4 Hz)
fp2_high = f_cutoff(3); % Frecuencia de paso superior (1142 Hz)
fs2_high = fc(3); % Frecuencia de rechazo superior (2560 Hz)

% Calcular orden considerando ambas transiciones
N2_low = calcular_orden_fir(fp2_low, fs2_low, Fs, ventana_tipo);
N2_high = calcular_orden_fir(fp2_high, fs2_high, Fs, ventana_tipo);
N2 = max(N2_low, N2_high);
fprintf('Orden del filtro: %d\n', N2);
fprintf('Ancho de transición inferior: %.2f Hz\n', fp2_low - fs2_low);
fprintf('Ancho de transición superior: %.2f Hz\n', fs2_high - fp2_high);

% Diseño del filtro FIR pasabanda
Wn2 = [f_cutoff(2) f_cutoff(3)] / (Fs/2);
b2_fir = fir1(N2, Wn2, 'bandpass', hamming(N2+1));

%% BANDA 3: Filtro Pasabanda (2560 Hz)
fprintf('\n=== BANDA 3: Pasabanda (fc = %.1f Hz) ===\n', fc(3));

% Frecuencias de diseño
fp3_low = f_cutoff(3); % Frecuencia de paso inferior (1142 Hz)
fs3_low = fc(2); % Frecuencia de rechazo inferior (512 Hz)
fp3_high = f_cutoff(4); % Frecuencia de paso superior (5702 Hz)
fs3_high = fc(4); % Frecuencia de rechazo superior (12800 Hz)

% Calcular orden considerando ambas transiciones
N3_low = calcular_orden_fir(fp3_low, fs3_low, Fs, ventana_tipo);
N3_high = calcular_orden_fir(fp3_high, fs3_high, Fs, ventana_tipo);
N3 = max(N3_low, N3_high);
fprintf('Orden del filtro: %d\n', N3);
fprintf('Ancho de transición inferior: %.2f Hz\n', fp3_low - fs3_low);
fprintf('Ancho de transición superior: %.2f Hz\n', fs3_high - fp3_high);

% Diseño del filtro FIR pasabanda
Wn3 = [f_cutoff(3) f_cutoff(4)] / (Fs/2);
b3_fir = fir1(N3, Wn3, 'bandpass', hamming(N3+1));

%% BANDA 4: Filtro Pasaaltos (12800 Hz)
fprintf('\n=== BANDA 4: Pasaaltos (fc = %.1f Hz) ===\n', fc(4));

% Frecuencias de diseño
fp4 = f_cutoff(4); % Frecuencia de paso (5702 Hz)
fs4 = fc(3); % Frecuencia de rechazo (2560 Hz)

% Calcular orden del filtro
N4 = calcular_orden_fir(fp4, fs4, Fs, ventana_tipo);
fprintf('Orden del filtro: %d\n', N4);
fprintf('Ancho de transición: %.2f Hz\n', fp4 - fs4);

% Diseño del filtro FIR pasaaltos
Wn4 = f_cutoff(4) / (Fs/2);
b4_fir = fir1(N4, Wn4, 'high', hamming(N4+1));

%% Visualización de respuestas en frecuencia
figure('Position', [100 100 1400 900]);

for banda = 1:4
    % Seleccionar los coeficientes correspondientes
    switch banda
        case 1
            b_fir = b1_fir;
            N_orden = N1;
            titulo = sprintf('Banda 1: Pasabajos (fc = %.1f Hz, Orden = %d)', fc(1), N_orden);
        case 2
            b_fir = b2_fir;
            N_orden = N2;
            titulo = sprintf('Banda 2: Pasabanda (fc = %.1f Hz, Orden = %d)', fc(2), N_orden);
        case 3
            b_fir = b3_fir;
            N_orden = N3;
            titulo = sprintf('Banda 3: Pasabanda (fc = %.1f Hz, Orden = %d)', fc(3), N_orden);
        case 4
            b_fir = b4_fir;
            N_orden = N4;
            titulo = sprintf('Banda 4: Pasaaltos (fc = %.1f Hz, Orden = %d)', fc(4), N_orden);
    end
    
    % Calcular respuesta en frecuencia
    [H_fir, f_fir] = freqz(b_fir, 1, 8192, Fs);
    
    % Gráfica
    subplot(2, 2, banda);
    plot(f_fir, 20*log10(abs(H_fir)), 'b-', 'LineWidth', 1.5);
    hold on;
    
    % Marcar frecuencia central
    plot(fc(banda), 0, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'g');
    
    % Añadir líneas de frecuencias de corte y adyacentes
    ylim_vals = [-80 5];
    
    switch banda
        case 1 % Pasabajos
            % Frecuencia de corte (media geométrica) - línea de -6dB
            yline(-6, 'r--', 'LineWidth', 1.5);
            plot([f_cutoff(2) f_cutoff(2)], ylim_vals, 'k--', 'LineWidth', 1);
            text(f_cutoff(2), -60, sprintf('%.1f Hz\n(-6dB)', f_cutoff(2)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8, 'BackgroundColor', 'white');
            % Frecuencia de la banda siguiente (atenuación -15dB)
            yline(-15, 'c--', 'LineWidth', 1.5);
            plot([fc(2) fc(2)], ylim_vals, 'm--', 'LineWidth', 1);
            text(fc(2), -25, sprintf('%.1f Hz\n(-15dB)', fc(2)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8, 'BackgroundColor', 'white');
            
        case 2 % Pasabanda (512 Hz)
            % Líneas de referencia de atenuación
            yline(-6, 'r--', 'LineWidth', 1.5);
            yline(-15, 'c--', 'LineWidth', 1.5);
            % Frecuencia de corte inferior
            plot([f_cutoff(2) f_cutoff(2)], ylim_vals, 'k--', 'LineWidth', 1);
            text(f_cutoff(2), -60, sprintf('%.1f Hz\n(-6dB)', f_cutoff(2)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8, 'BackgroundColor', 'white');
            % Frecuencia de corte superior
            plot([f_cutoff(3) f_cutoff(3)], ylim_vals, 'k--', 'LineWidth', 1);
            text(f_cutoff(3), -60, sprintf('%.1f Hz\n(-6dB)', f_cutoff(3)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8, 'BackgroundColor', 'white');
            % Frecuencia banda anterior (atenuación -15dB)
            plot([fc(1) fc(1)], ylim_vals, 'm--', 'LineWidth', 1);
            text(fc(1), -25, sprintf('%.1f Hz\n(-15dB)', fc(1)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8, 'BackgroundColor', 'white');
            % Frecuencia banda posterior (atenuación -15dB)
            plot([fc(3) fc(3)], ylim_vals, 'm--', 'LineWidth', 1);
            text(fc(3), -25, sprintf('%.1f Hz\n(-15dB)', fc(3)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8, 'BackgroundColor', 'white');
            
        case 3 % Pasabanda (2560 Hz)
            % Líneas de referencia de atenuación
            yline(-6, 'r--', 'LineWidth', 1.5);
            yline(-15, 'c--', 'LineWidth', 1.5);
            % Frecuencia de corte inferior
            plot([f_cutoff(3) f_cutoff(3)], ylim_vals, 'k--', 'LineWidth', 1);
            text(f_cutoff(3), -60, sprintf('%.1f Hz\n(-6dB)', f_cutoff(3)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8, 'BackgroundColor', 'white');
            % Frecuencia de corte superior
            plot([f_cutoff(4) f_cutoff(4)], ylim_vals, 'k--', 'LineWidth', 1);
            text(f_cutoff(4), -60, sprintf('%.1f Hz\n(-6dB)', f_cutoff(4)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8, 'BackgroundColor', 'white');
            % Frecuencia banda anterior (atenuación -15dB)
            plot([fc(2) fc(2)], ylim_vals, 'm--', 'LineWidth', 1);
            text(fc(2), -25, sprintf('%.1f Hz\n(-15dB)', fc(2)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8, 'BackgroundColor', 'white');
            % Frecuencia banda posterior (atenuación -15dB)
            plot([fc(4) fc(4)], ylim_vals, 'm--', 'LineWidth', 1);
            text(fc(4), -25, sprintf('%.1f Hz\n(-15dB)', fc(4)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8, 'BackgroundColor', 'white');
            
        case 4 % Pasaaltos
            % Líneas de referencia de atenuación
            yline(-6, 'r--', 'LineWidth', 1.5);
            yline(-15, 'c--', 'LineWidth', 1.5);
            % Frecuencia de corte
            plot([f_cutoff(4) f_cutoff(4)], ylim_vals, 'k--', 'LineWidth', 1);
            text(f_cutoff(4), -60, sprintf('%.1f Hz\n(-6dB)', f_cutoff(4)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8, 'BackgroundColor', 'white');
            % Frecuencia banda anterior (atenuación -15dB)
            plot([fc(3) fc(3)], ylim_vals, 'm--', 'LineWidth', 1);
            text(fc(3), -25, sprintf('%.1f Hz\n(-15dB)', fc(3)), ...
                'HorizontalAlignment', 'center', 'FontSize', 8, 'BackgroundColor', 'white');
    end
    
    grid on;
    xlabel('Frecuencia (Hz)');
    ylabel('Magnitud (dB)');
    title(titulo);
    legend('Respuesta FIR', 'Frecuencia Central', 'Location', 'best');
    xlim([20 Fs/2]);
    ylim(ylim_vals);
    set(gca, 'XScale', 'log');
end

sgtitle('Respuestas en Frecuencia - Filtros FIR (Ventana Hamming)');

%% Visualización de respuestas de fase (lineales)
figure('Position', [100 100 1400 900]);

for banda = 1:4
    switch banda
        case 1
            b_fir = b1_fir;
            titulo = sprintf('Banda 1: Fase Lineal');
        case 2
            b_fir = b2_fir;
            titulo = sprintf('Banda 2: Fase Lineal');
        case 3
            b_fir = b3_fir;
            titulo = sprintf('Banda 3: Fase Lineal');
        case 4
            b_fir = b4_fir;
            titulo = sprintf('Banda 4: Fase Lineal');
    end
    
    [H_fir, f_fir] = freqz(b_fir, 1, 8192, Fs);
    phase = unwrap(angle(H_fir)) * 180/pi;
    
    subplot(2, 2, banda);
    plot(f_fir, phase, 'b-', 'LineWidth', 1.5);
    grid on;
    xlabel('Frecuencia (Hz)');
    ylabel('Fase (grados)');
    title(titulo);
    set(gca, 'XScale', 'log');
    xlim([20 Fs/2]);
end

sgtitle('Respuestas de Fase - Filtros FIR (Fase Lineal)');

%% Función del ecualizador FIR
function y = ecualizador_FIR(x, G1, G2, G3, G4, b1, b2, b3, b4)
    % Filtrar cada banda
    y1 = filter(b1, 1, x) * G1;
    y2 = filter(b2, 1, x) * G2;
    y3 = filter(b3, 1, x) * G3;
    y4 = filter(b4, 1, x) * G4;
    
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
y_eq = ecualizador_FIR(x_test, G1, G2, G3, G4, b1_fir, b2_fir, b3_fir, b4_fir);

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

sgtitle('Comparación Espectral: Original vs Ecualizado (FIR)');

%% Respuesta global del sistema
figure('Position', [100 100 1000 400]);

% Calcular respuesta combinada
[H1, f] = freqz(b1_fir, 1, 8192, Fs);
[H2, ~] = freqz(b2_fir, 1, 8192, Fs);
[H3, ~] = freqz(b3_fir, 1, 8192, Fs);
[H4, ~] = freqz(b4_fir, 1, 8192, Fs);

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
title('Respuesta en Frecuencia del Ecualizador Completo (FIR)');
legend('Total', 'Banda 1', 'Banda 2', 'Banda 3', 'Banda 4', 'Location', 'best');
set(gca, 'XScale', 'log');
xlim([20 Fs/2]);

%% Tabla resumen
fprintf('\n=== RESUMEN DE DISEÑO FIR ===\n');
fprintf('Ventana utilizada: %s\n', upper(ventana_tipo));
fprintf('Atenuación en banda de paso: %.1f dB\n', Ap);
fprintf('Atenuación en banda eliminada: %.1f dB\n', As);
fprintf('\nÓrdenes de los filtros:\n');
fprintf('  Banda 1 (Pasabajos):    N = %d\n', N1);
fprintf('  Banda 2 (Pasabanda):    N = %d\n', N2);
fprintf('  Banda 3 (Pasabanda):    N = %d\n', N3);
fprintf('  Banda 4 (Pasaaltos):    N = %d\n', N4);
fprintf('\nVentaja FIR: Fase lineal (sin distorsión de fase)\n');
fprintf('Desventaja FIR: Mayor orden que IIR para mismas especificaciones\n');

fprintf('\nEcualizador FIR diseñado exitosamente.\n');