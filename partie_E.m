clear; clc;

NB = 512;

Fs = 48000;  

N      = 10;     
Fstop1 = 4200;   
Fstop2 = 16600;  
Astop  = 48;     

%-------------------------------------------------------------------------
%-----------------Expliquer le choix des paramètres-----------------------
%-------------------------------------------------------------------------
% N = ordre du filtre
% Fstop1, Fstop2 = bande passante
% Astop = atténuation dans la bande atténuée
% Fs = fréquence d'échantillonnage
h  = fdesign.bandpass('N,Fst1,Fst2,Ast', N, Fstop1, Fstop2, Astop, Fs);
Hd = design(h, 'cheby2');
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%-----------------générer les figures E).1--------------------------------
%-------------------------------------------------------------------------
[hn,idx] = impz(Hd);
[H,w_Hz] = freqz(Hd,[],Fs);
Ns=N+1;
figure(1);clf;
stem(idx, hn, '--o',"filled","LineWidth",2);
xlabel('sample ')
ylabel('Magnitude')
grid on;

figure(2);clf;
freq = w_Hz / 1000;
ax = plotyy(freq, 20*log10(abs(H)), freq, unwrap(angle(H)));
xlabel('Frequency [kHz]')
ylabel(ax(1), 'Magnitude (dB)')
ylabel(ax(2), 'Phase (rad)')
grid on

figure(3);clf;
gd = - diff(unwrap(angle(H)) / (2 * pi)) * 1000;
%[gd, w_gd] = grpdelay(Hd, NB, Fs);
%freq = w_gd ./ 1000;
plot(freq(1:end - 1), gd);
ylim([0,20]);
xlabel('Frequency [kHz]')
ylabel('group delay [ms]')
grid on;
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%-----------------générer la figure E).2----------------------------------
%-------------------------------------------------------------------------
[num, den] = tf(Hd);
sos = tf2sos(num, den);
[z, p, k] = sos2zp(sos, 1);

figure(4);clf;hold on;
plot(cos(pi*(0:0.01:2)),sin(pi*(0:0.01:2)),'r', 'DisplayName', 'Cercle unité');
hZ = plot(real(z), imag(z),'ok','linewidth',2, 'DisplayName', 'Zéros');
hP = plot(real(p), imag(p),'xk','linewidth',3, 'DisplayName', 'Pôles');
grid on;
axis equal;
legend([hZ hP], 'Location', 'best'); % Affiche uniquement Zéros et Pôles
%-------------------------------------------------------------------------


%%
%-------------------------------------------------------------------------
%-----------------générer la figure E).3----------------------------------
%-------------------------------------------------------------------------
figure(5);clf;
[music, fs] = audioread('funky.wav');
N_samples =length(music);
tic;
musicF=sosfilt(sos, music);
toc

subplot(2,2,1);plot(music);
subplot(2,2,2);specgram(music,512,Fs/1000);ylabel('Frequency [kHz]');set(gca, 'XTick', []);
subplot(2,2,3);plot(musicF);
subplot(2,2,4);specgram(musicF,512,Fs/1000);ylabel('Frequency [kHz]');set(gca, 'XTick', []);

sound(musicF/max(musicF)/2,Fs);
