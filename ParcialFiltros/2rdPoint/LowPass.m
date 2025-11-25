
fs = 64000;
Rp = 3;
As = 15;

f_0 =102.4;
fc_2= 512;
fc_1 = sqrt(f_0*fc_2); % Media Geometrica



% Normalizar para buttord
W1 = fc_1/(fs/2);
W2 = fc_2/(fs/2);


[n,Wn]=buttord(W1,W2,Rp, As);


[b,a] = butter(n,Wn,"low");

[bz,az] = impinvar(b,a,fs)

%% Compute frequency response
figure
freqz(bz, az, 1, fs);   % f is in Hz

%% Convert to kHz
%%f_kHz = f ;

