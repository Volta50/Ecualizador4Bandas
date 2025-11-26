% IIR_00 - Pasabajos

fs = 64000;% Frecuencia de muestreo
Rp = 3;% Ripple de banda de paso
As = 15;% Atenuacion en banda de rechazo

mayorOrden = 3;

%Frecuencias a utilizar

f_central =512;%frecuencia c
f_stop_low = 102.4;
f_stop_high = 2560;

f_pass_low =  sqrt(f_central*f_stop_low);
f_pass_high =  sqrt(f_central*f_stop_high);

Wp = [f_pass_low   f_pass_high];
Ws = [f_stop_low   f_stop_high];


% Normalizar para buttord
Wp = Wp/(fs/2);
Ws = Ws/(fs/2);




[n,Wn]=buttord(Wp, Ws, Rp, As)
n = mayorOrden;%Asignación del mayor orden


[b,a] = butter(n,Wn,"bandpass");
sos = tf2sos(b,a);

freqz(sos,1024,fs)
title(sprintf('n = %d Butterworth Lowpass Filter',n))

fc1 = fc_1/1000;% in kHz
fc2 = fc_2/1000;% in kHz


% Add vertical lines

Wp = [f_pass_low   f_pass_high];
Ws = [f_stop_low   f_stop_high];

xline(f_pass_low/1000, 'r--', 'LineWidth', 1.3);   % cutoff
xline(f_pass_high/1000, 'r--', 'LineWidth', 1.3);   % stopband edge
xline(f_stop_low/1000, 'b--', 'LineWidth', 1.3);   % cutoff
xline(f_stop_high/1000, 'b--', 'LineWidth', 1.3);   % stopband edge
yline(-Rp, 'g--', 'LineWidth', 1.3);   % stopband edge
yline(-As, 'v--', 'LineWidth', 1.3);   % stopband edge

% (Optional) Add labels near the lines
text(fc1, -5, ' f_c', 'Color','r','FontSize',12);
text(fc2, -5, ' f_s', 'Color','m','FontSize',12);
