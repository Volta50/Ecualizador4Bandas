% === Determinación del mayor orden entre 4 bandas para IIR (corrigido) ===
clear; clc; close all;

% === Parámetros comunes ===
fs = 64000;        % Hz (muestreo)
Rp = 3;            % dB ripple en banda de paso
As = 15;           % dB atenuación en banda de rechazo

% Frecuencias centrales (progresión logarítmica factor 5)
f_centers = [102.4, 512, 2560, 12800];

% Calcular bordes por medias geométricas entre centros adyacentes
f_edges = sqrt(f_centers(1:end-1) .* f_centers(2:end)); % 3 bordes

% Mostrar datos
fprintf('Fs = %d Hz\n', fs);
fprintf('Frecuencias centrales: %s\n', mat2str(f_centers));
fprintf('Bordes (media geométrica): %s\n\n', mat2str(f_edges));

% === Especificaciones por banda (en Hz) ===
% Band 1: lowpass  (banda baja, corte en f_edges(1), stop en f_centers(2))
bands(1).type = 'low';
bands(1).Wp_h = f_edges(1);
bands(1).Ws_h = f_centers(2);

% Band 2: bandpass (entre f_edges(1) y f_edges(2), stops en f_centers(1) y f_centers(3))
bands(2).type = 'bandpass';
bands(2).Wp_h = [f_edges(1) f_edges(2)];
bands(2).Ws_h = [f_centers(1) f_centers(3)];

% Band 3: bandpass (entre f_edges(2) y f_edges(3), stops en f_centers(2) y f_centers(4))
bands(3).type = 'bandpass';
bands(3).Wp_h = [f_edges(2) f_edges(3)];
bands(3).Ws_h = [f_centers(2) f_centers(4)];

% Band 4: highpass (banda alta, corte en f_edges(3), stop en f_centers(3))
bands(4).type = 'high';
bands(4).Wp_h = f_edges(3);
bands(4).Ws_h = f_centers(3);

% Prealocar
orders_bilinear = zeros(1,4);
orders_impinvar  = zeros(1,4);

% === Loop sobre bandas ===
for k = 1:4
    btype = bands(k).type;
    Wp_h = bands(k).Wp_h;   % pass edge(s) en Hz
    Ws_h = bands(k).Ws_h;   % stop edge(s) en Hz

    % --- Método: BILINEAL (prewarp) ---
    % Prewarp: Omega = 2*fs * tan(pi * f / fs)  (rad/s)
    if strcmp(btype,'bandpass')
        % Asegurar vectores fila y orden correcto
        Wp_h = sort(Wp_h(:))';
        Ws_h = sort(Ws_h(:))';
        Omega_p_b = 2*fs .* tan(pi .* (Wp_h ./ fs));
        Omega_s_b = 2*fs .* tan(pi .* (Ws_h ./ fs));
    else
        % low o high: escala simple
        Wp_h = double(Wp_h);
        Ws_h = double(Ws_h);
        Omega_p_b = 2*fs * tan(pi * (Wp_h / fs));
        Omega_s_b = 2*fs * tan(pi * (Ws_h / fs));
    end

    % Buttord en dominio analógico ('s') usando las Omegas prewarpeadas
    % Aseguramos que los vectores estén en el formato esperado
    try
        [n_b, Wn_b] = buttord(Omega_p_b, Omega_s_b, Rp, As, 's');
    catch ME
        % En caso de error, intentamos ordenar y volver a calcular
        warning('buttord (bilinear) falló en banda %d (%s). Intentando ordenar/ajustar...', k, btype);
        Omega_p_b = sort(Omega_p_b(:))';
        Omega_s_b = sort(Omega_s_b(:))';
        [n_b, Wn_b] = buttord(Omega_p_b, Omega_s_b, Rp, As, 's');
    end
    orders_bilinear(k) = n_b;

    % --- Método: IMPULSE-INVARIANCE ---
    % Diseñamos prototipo analógico usando Omega = 2*pi*f (rad/s)
    if strcmp(btype,'bandpass')
        Wp_h = sort(Wp_h(:))';    % asegurar orden
        Ws_h = sort(Ws_h(:))';
        Omega_p_i = 2*pi .* Wp_h;
        Omega_s_i = 2*pi .* Ws_h;
    else
        Omega_p_i = 2*pi * Wp_h;
        Omega_s_i = 2*pi * Ws_h;
    end

    try
        [n_i, Wn_i] = buttord(Omega_p_i, Omega_s_i, Rp, As, 's');
    catch ME
        warning('buttord (impinvar) falló en banda %d (%s). Intentando ordenar/ajustar...', k, btype);
        Omega_p_i = sort(Omega_p_i(:))';
        Omega_s_i = sort(Omega_s_i(:))';
        [n_i, Wn_i] = buttord(Omega_p_i, Omega_s_i, Rp, As, 's');
    end
    orders_impinvar(k) = n_i;

    % Imprimir resultados por banda
    fprintf('Banda %d (%s):\n', k, btype);
    fprintf('  Wp (Hz) = %s\n', mat2str(bands(k).Wp_h));
    fprintf('  Ws (Hz) = %s\n', mat2str(bands(k).Ws_h));
    fprintf('  Orden (bilinear / prewarp) = %d\n', n_b);
    fprintf('  Orden (impinvar, prototipo analogico) = %d\n\n', n_i);
end

% === Resultado final: orden mayor entre todos los diseños ===
max_order = max([orders_bilinear, orders_impinvar]);
fprintf('=== RESULTADO ===\nMayor orden requerido entre todos los filtros (ambos métodos): %d\n', max_order);

% === Opcional: mostrar vector de órdenes individuales ===
disp('Órdenes por banda (bilinear):'); disp(orders_bilinear);
disp('Órdenes por banda (impinvar):');  disp(orders_impinvar);

% Fin del script
