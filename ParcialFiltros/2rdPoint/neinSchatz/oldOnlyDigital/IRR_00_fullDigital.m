% IIR_00 - Pasabajos


fs = 64000;% Frecuencia de muestreo
Rp = 3;% Ripple de banda de paso
As = 15;% Atenuacion en banda de rechazo

mayorOrden = 3;

%Frecuencias a utilizar
f_0 =102.4;%frecuencia central
fc_2= 512;%frecuencia de rechazo
fc_1 = sqrt(f_0*fc_2); % Frecuencia cut-off(Media Geometrica)



% Normalizar para buttord
W1 = fc_1/(fs/2);
W2 = fc_2/(fs/2);




[n,Wn]=buttord(W1, W2, Rp, As)
n = mayorOrden;%Asignación del mayor or


[b,a] = butter(n,Wn,"low");
sos = tf2sos(b,a);

freqz(sos,512,fs)
title(sprintf('n = %d Butterworth Lowpass Filter',n))

fc1 = fc_1/1000;% in kHz
fc2 = fc_2/1000;% in kHz


% Add vertical lines
xline(fc1, 'r--', 'LineWidth', 1.3);   % cutoff
xline(fc2, 'm--', 'LineWidth', 1.3);   % stopband edge
yline(-Rp, 'b--', 'LineWidth', 1.3);   % stopband edge
yline(-As, 'v--', 'LineWidth', 1.3);   % stopband edge

% (Optional) Add labels near the lines
text(fc1, -5, ' f_c', 'Color','r','FontSize',12);
text(fc2, -5, ' f_s', 'Color','m','FontSize',12);
