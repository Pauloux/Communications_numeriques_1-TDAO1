clear; clc; close all;

NB = 512;

Fs = 48000;

N      = 30;
Fstop1 = 4000;
Fpass1 = 6000;
Fpass2 = 14000;
Fstop2 = 16000;
Wstop1 = 60;
Wpass  = 1;
Wstop2 = 60;
dens   = 20;
%-------------------------------------------------------------------------
%-----------------Expliquer le choix des paramètres-----------------------
%-------------------------------------------------------------------------
% firpm(N = ordre du filtre, [fréquences normalisés], [amplitude], poids d'erreur = tolérance d'ondulations, élevé=petite tolérance, density of frequency grid)
b  = firpm(N, [0 Fstop1 Fpass1 Fpass2 Fstop2 Fs/2]/(Fs/2), [0 0 1 1 0 ...
           0], [Wstop1 Wpass Wstop2], {dens});
Hd = dfilt.dffir(b);    % Créer un objet pour le filtre
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%--------------------générer la figure D).1-------------------------------
%-------------------------------------------------------------------------
[H,w] = freqz(b,1,NB);
figure(12);clf;
freq = w./(2 * pi) .* Fs ./ 1000;
ax = plotyy(freq, 20*log10(abs(H)), freq, unwrap(angle(H)));
ylim([-80,5]);
xlabel('Frequency [kHz]')
ylabel(ax(1), 'Magnitude (dB)')
ylabel(ax(2), 'Phase (rad)')
grid on;
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%--------------------générer les figures D).2-----------------------------
%-------------------------------------------------------------------------
Ns=N+1;
figure(11);clf;
stem(0:N, b,'--o',"filled","LineWidth",2);
xlabel('sample ')
ylabel('Magnitude')
xlim([0, 30]);
grid on;

figure(13);clf;
gd = - diff(unwrap(angle(H))) / (2 * pi);

plot(freq(1:end - 1), gd, 'b', 'LineWidth', 1.5);
xlabel('Frequency [kHz]')
ylabel('group delay')
grid on;
%-------------------------------------------------------------------------


%%
%-------------------------------------------------------------------------
%--------------------générer la figure D).3-------------------------------
%-------------------------------------------------------------------------
figure(14);clf;
[music, fs] = audioread('funky.wav');
N_samples =length(music);
tic;
musicF=filter(b, 1, music);
toc
subplot(2,2,1);plot(music);
subplot(2,2,2);specgram(music,512,Fs/1000);ylabel('Frequency [kHz]');set(gca, 'XTick', []);
subplot(2,2,3);plot(musicF);
subplot(2,2,4);specgram(musicF,512,Fs/1000);ylabel('Frequency [kHz]');set(gca, 'XTick', []);
% -------------------------------------------------------------------------

sound(musicF/max(musicF)/2,Fs);
