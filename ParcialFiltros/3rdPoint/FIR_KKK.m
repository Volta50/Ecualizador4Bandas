fs= 64000;

As = 15;

f_cntral = [102.4,512,2560,12800];
f_pass = zeros(1,4);

for i= 1:3
    f_pass(i) = sqrt(f_cntral(i)*f_cntral(i+1))
end
f_pass(4)= fs/2;                    % Para el ultimo filtro pseudo pasaltos, dejarlo como la frecuencia de nyquist reduce el orden






%===========Diseño de pasabajos 01
f_p1= f_pass(1)
f_s1= f_cntral(2)

w_trBand1 = f_s1-f_p1;               %Width of the transition band
%============Harris aprox
N1 =ceil((fs/w_trBand1)*(As/22))  

N1 =210                             % Valor hallado tras múltiples iteraciones
%============Determinación de coef 
Wp1 = f_p1/(fs/2)                   %Se normaliza la frecuencia de paso dividiendo por la frecuencia de Nyquist
w_hann1 = hann(N1+1);                 % Creación de la ventana Hanning
B1 = fir1(N1,Wp1,"low",w_hann1);
    
%============Visualización
figure;
freqz(B1,1,2048,fs)
yline(-6)
yline(-15)
xline(f_p1/1000,'r')                          % Frecuencia de paso normalizada
xline(f_s1/1000,'b')                % Frecuencia de rechazo normalizad
xline(f_cntral(1),'r--')






%===========Diseño de pasabandas 02
f_p2L= f_pass(1)
f_s2L= f_cntral(1)
f_p2H= f_pass(2)
f_s2H= f_cntral(3)



w_trBand2 = min(abs(f_p2L-f_s2L),  abs(f_s2H-f_p2H))              %Width of the transition band

%============Harris aprox
N2 =ceil(2*(fs/w_trBand2)*(As/22))  %Multiplicada por dos dado q es un pasabajos

N2 =700                            % Valor hallado tras múltiples iteraciones
%============Determinación de coef 
Wp2 = [f_p2L/(fs/2) f_p2H/(fs/2)]                    %Se normaliza la frecuencia de paso dividiendo por la frecuencia de Nyquist
w_hann2 = hann(N2+1);                 % Creación de la ventana Hanning
B2 = fir1(N2,Wp2,"bandpass",w_hann2);

%============Visualización
figure;
freqz(B2,1,2048,fs)
yline(-6,'g--')
yline(-15,'v--')
xline(f_p2H/1000,'r--')                          % Frecuencia de paso normalizada
xline(f_p2L/1000,'r--')

xline(f_s2L/1000,'b--')                % Frecuencia de rechazo normalizad
xline(f_s2H/1000,'b--')    
xline(f_cntral(2)/1000)





%===========Diseño de pasabandas 03
f_p3L= f_pass(2)
f_s3L= f_cntral(2)
f_p3H= f_pass(3)
f_s3H= f_cntral(4)



w_trBand3 = min(abs(f_p3L-f_s3L),  abs(f_s3H-f_p3H))              %Width of the transition band, choose smallest width

%============Harris aprox
N3 =ceil(2*(fs/w_trBand3)*(As/22))  %Multiplicada por dos dado q es un pasabajos

%N3 =700                            % Valor hallado tras múltiples iteraciones
%============Determinación de coef 
Wp3 = [f_p3L/(fs/2) f_p3H/(fs/2)]                    %Se normaliza la frecuencia de paso dividiendo por la frecuencia de Nyquist
w_hann3 = hann(N3+1);                 % Creación de la ventana Hanning
B3 = fir1(N3,Wp3,"bandpass",w_hann3);

%============Visualización
figure;
freqz(B3,1,2048,fs)
yline(-6,'g--')
yline(-15,'v--')
xline(f_p3H/1000,'r--')                          % Frecuencia de paso normalizada
xline(f_p3L/1000,'r--')

xline(f_s3L/1000,'b--')                % Frecuencia de rechazo normalizad
xline(f_s3H/1000,'b--')    
xline(f_cntral(3)/1000)




%===========Diseño de pasaaltos 04
f_p4= f_pass(3)
f_s4= f_cntral(3)

w_trBand4 = abs(f_s4-f_p4);              %Width of the transition band
%============Harris aprox
N4 =ceil((fs/w_trBand4)*(As/22))  

N4 =26                             % Valor hallado tras múltiples iteraciones
%============Determinación de coef 
Wp4 = f_p4/(fs/2)                   %Se normaliza la frecuencia de paso dividiendo por la frecuencia de Nyquist
w_hann4 = hann(N4+1);                 % Creación de la ventana Hanning
B4 = fir1(N4,Wp4,'high',w_hann4);
    
%============Visualización
figure;
freqz(B4,1,2048,fs)
yline(-6)
yline(-15)
xline(f_p4/1000,'r')                          % Frecuencia de paso normalizada
xline(f_s4/1000,'b')                % Frecuencia de rechazo normalizad
xline(f_cntral(4),'r--')


