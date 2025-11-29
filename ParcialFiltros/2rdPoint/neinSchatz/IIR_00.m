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
figure
freqz(sos_imp,2048,fs)
title(sprintf('f_{central} = %0.1f Lowpass Filter-ImpulseInvariance',f_central))



xline(f_pass/1000, 'r--', 'LineWidth', 1.3);   % cutoff
xline(f_stop/1000, 'b--', 'LineWidth', 1.3);   % stopband edge
yline(-Rp, 'g--', 'LineWidth', 1.3);   % stopband edge
yline(-As, 'v--', 'LineWidth', 1.3);   % stopband edge

% (Optional) Add labels near the lines
text(f_pass, -5, ' f_pass', 'Color','r','FontSize',12);
text(f_stop, -5, ' f_stop', 'Color','m','FontSize',12);

%===================================


figure
freqz(sos_bi,2048,fs)
title(sprintf('f_{central} = %0.1f Lowpass Filter - Bilinear Transform',f_central))



% Add vertical lines


xline(f_pass/1000, 'r--', 'LineWidth', 1.3);   % cutoff
xline(f_stop/1000, 'b--', 'LineWidth', 1.3);   % stopband edge
yline(-Rp, 'g--', 'LineWidth', 1.3);   % stopband edge
yline(-As, 'v--', 'LineWidth', 1.3);   % stopband edge

% (Optional) Add labels near the lines
text(f_pass, -5, ' f_pass', 'Color','r','FontSize',12);
text(f_stop, -5, ' f_stop', 'Color','m','FontSize',12);

