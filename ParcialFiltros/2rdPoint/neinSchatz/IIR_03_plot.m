
% IIR_01 - Pasabanda

fs = 64000;% Frecuencia de muestreo
Rp = 3;% Ripple de banda de paso
As = 15;% Atenuacion en banda de rechazo

mayorOrden = 3;%Obtenido de mayorOrdenGG.m

%Frecuencias a utilizar

f_central =12800;%frecuencia c
f_stop_low = 2560;
f_stop_high = 12800*5;

f_pass_low =  sqrt(f_central*f_stop_low);
f_pass_high =  sqrt(f_central*f_stop_high);

Wp = [f_pass_low   f_pass_high];
Ws = [f_stop_low   f_stop_high];



% Normalizar para buttord
Wp = 2*pi*Wp;
Ws = 2*pi*Ws;




[n,Wn]=buttord(Wp, Ws, Rp, As,'s')
n = mayorOrden;%Asignación del mayor orden


[b_bp,a_bp] = butter(n,Wn,'bandpass','s');
[bz_imp, az_imp] = impinvar(b_bp,a_bp,fs);


%====Pasaaltos para el bilinear

Wp_hp = 2*pi*f_pass_low;
Ws_hp = 2*pi*f_stop_low;

[n,Wn_hp]=buttord(Wp_hp, Ws_hp, Rp, As,'s');
[b_hp, a_hp] = butter(n,Wn_hp,'high','s');


[bz_bi, az_bi] = bilinear(b_hp,a_hp,fs);

sos_imp = tf2sos(bz_imp,az_imp);
sos_bi = tf2sos(bz_bi, az_bi);




% suponer sos_imp ya definido y fs definido
Nfft = 4096;
[H, F] = freqz(sos_imp, Nfft, fs);   % H (complex), F (Hz)

% Plot magnitud (dB)
figure;
subplot(2,1,1);
plot(F, 20*log10(abs(H)));
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Magnitude response (Impulse Invariance)');
xlim([0 fs/2]);    % por ejemplo

% Añadir líneas en el subplot de magnitud
hold on;
xline(f_pass_low,  'r--','LineWidth',1.2);
xline(f_pass_high, 'r--','LineWidth',1.2);
xline(f_stop_low,  'b--','LineWidth',1.2);
xline(f_stop_high, 'b--','LineWidth',1.2);
yline(-Rp,'g--','LineWidth',1.2);
yline(-As,'v--','LineWidth',1.2);

% Plot fase
subplot(2,1,2);
plot(F, unwrap(angle(H)) * 180/pi);  % fase en grados, desempaquetada
grid on;
xlabel('Frequency (Hz)');
ylabel('Phase (deg)');
xlim([0 20000]);

