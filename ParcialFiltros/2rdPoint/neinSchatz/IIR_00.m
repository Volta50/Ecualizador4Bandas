% IIR_00 - Pasabajos

fs = 64000;% Frecuencia de muestreo
Rp = 3;% Ripple de banda de paso
As = 15;% Atenuacion en banda de rechazo

mayorOrden = 3;%Obtenido de mayorOrdenGG.m

%Frecuencias a utilizar

f_central =102.4;

f_stop = 512;

f_pass=  sqrt(f_central*f_stop);

Wp = [f_pass];
Ws = [f_stop];


% Normalizar para buttord
Wp = 2*pi*Wp;
Ws = 2*pi*Ws;




[n,Wn]=buttord(Wp, Ws, Rp, As,'s')
n = mayorOrden;%Asignación del mayor orden


[b,a] = butter(n,Wn,'low','s');
[bz_imp, az_imp] = impinvar(b,a,fs);
[bz_bi, az_bi] = bilinear(b,a,fs);

sos_imp = tf2sos(bz_imp,az_imp);
sos_bi = tf2sos(bz_bi, az_bi);

%=========================================
figure(1)
freqz(sos_imp,2048,fs)
title(sprintf('f_central = %0.1f Lowpass Filter-ImpulseInvariance',f_central))

fc1 = fc_1/1000;% in kHz
fc2 = fc_2/1000;% in kHz


% Add vertical lines

Wp = [f_pass_low   f_pass_high];
Ws = [f_stop_low   f_stop_high];

xline(f_pass/1000, 'r--', 'LineWidth', 1.3);   % cutoff
xline(f_stop/1000, 'b--', 'LineWidth', 1.3);   % stopband edge
yline(-Rp, 'g--', 'LineWidth', 1.3);   % stopband edge
yline(-As, 'v--', 'LineWidth', 1.3);   % stopband edge

% (Optional) Add labels near the lines
text(fc1, -5, ' f_c', 'Color','r','FontSize',12);
text(fc2, -5, ' f_s', 'Color','m','FontSize',12);

%===================================
figure(2)
freqz(sos_bi,2048,fs)
title(sprintf('f_{central} = %0.1f Lowpass Filter - Bilinear Transform',f_central))



% Add vertical lines

Wp = [f_pass_low   f_pass_high];
Ws = [f_stop_low   f_stop_high];

xline(f_pass/1000, 'r--', 'LineWidth', 1.3);   % cutoff
xline(f_stop/1000, 'b--', 'LineWidth', 1.3);   % stopband edge
yline(-Rp, 'g--', 'LineWidth', 1.3);   % stopband edge
yline(-As, 'v--', 'LineWidth', 1.3);   % stopband edge

% (Optional) Add labels near the lines
text(fc1, -5, ' f_c', 'Color','r','FontSize',12);
text(fc2, -5, ' f_s', 'Color','m','FontSize',12);

