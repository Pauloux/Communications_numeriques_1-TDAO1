clc;
clear;
close all;
%pkg load signal; % Pour GNU Octave

%% Paramètres et réponse impulsionnelle

Fe = 1000; % Fréquence d'échantillonnage en Hz
F1 = 200;  % Fréquence de coupure basse en Hz
F2 = 300;  % Fréquence de coupure haute en Hz
N = 9;     % Nombre de coefficients (longueur de la fenêtre de troncature)

n = 0:N-1; % Vecteur des indices des échantillons temporels
retard = (N-1)/2; % Retard appliqué pour rendre le filtre causal

% Calcul de la réponse impulsionnelle causale hhat(n)
hhat = 2*(F2/Fe)*sinc(2*(F2/Fe)*(n - retard)) - 2*(F1/Fe)*sinc(2*(F1/Fe)*(n - retard));

% Tracé de la réponse impulsionnelle
figure(1); clf; hold on;
stem(n, hhat, 'b', 'LineWidth', 1.5, 'DisplayName', ['N = ' num2str(N)]);
legend;
grid on;
title('Réponse impulsionnelle d''un filtre passe-bande entre 200 et 300 Hz tronqué et rendu causal');
xlabel('Numéro d''échantillon (n)');
ylabel('Amplitude');
xlim([0, 8]);
hold off;

%% Réponse fréquentielle et retard de groupe

N_fft = 1024; % Nombre de points
H = fft(hhat, N_fft);
f = linspace(0, Fe, N_fft);

% On ne garde que la première moitié du spectre (critère de Nyquist)
f_demi = f(1:N_fft/2);
H_demi = H(1:N_fft/2);

Gain = abs(H_demi);
Gain_dB = 20*log10(Gain);

% Calcul de la phase et du retard de groupe (en échantillons)
Phase = unwrap(angle(H_demi));
d_omega_norm = 2 * pi * (f_demi(2) - f_demi(1)) / Fe;
Retard_groupe = -diff(Phase) / d_omega_norm;
f_retard = f_demi(1:end-1);

%% Évaluation des performances

Lvmax = max(Gain);
Lv1 = 0.1605; % Niveau de référence pour les lobes secondaires
Lv2 = Lv1;
Niveau_transition = Lvmax / 2;

% Analyse de la montée (avant le centre du filtre à 250 Hz)
indices_montee = find(f_demi < 250);
f_montee = f_demi(indices_montee);
Gain_montee = Gain(indices_montee);

idx_fL1 = find(Gain_montee <= Lv1, 1, 'last');
fL1 = f_montee(idx_fL1);

idx_fR1 = find(Gain_montee >= Niveau_transition, 1, 'first');
fR1 = f_montee(idx_fR1);

% Analyse de la descente (après le centre du filtre à 250 Hz)
indices_descente = find(f_demi >= 250);
f_descente = f_demi(indices_descente);
Gain_descente = Gain(indices_descente);

idx_fL2 = find(Gain_descente <= Niveau_transition, 1, 'first');
fL2 = f_descente(idx_fL2);

idx_fR2 = find(Gain_descente <= Lv2, 1, 'first');
fR2 = f_descente(idx_fR2);

% Calcul des pentes en dB/decade
Gain_dB_fL1 = 20*log10(Gain_montee(idx_fL1));
Gain_dB_fR1 = 20*log10(Gain_montee(idx_fR1));
Gain_dB_fL2 = 20*log10(Gain_descente(idx_fL2));
Gain_dB_fR2 = 20*log10(Gain_descente(idx_fR2));

p1 = (Gain_dB_fR1 - Gain_dB_fL1) / log10(fR1 / fL1);
p2 = (Gain_dB_fR2 - Gain_dB_fL2) / log10(fR2 / fL2);

%% Affichage des graphiques (gain et retard de groupe)
figure(2); clf;

% tracé du gain
subplot(2,1,1); hold on;
plot(f_demi, Gain, 'b', 'LineWidth', 1.5);

% Lignes de repères
yline(Lvmax, 'k--', 'Lvmax', 'LabelHorizontalAlignment', 'left');
yline(Lv1, 'k--', 'Lv1/Lv2', 'LabelHorizontalAlignment', 'left');
xline(fL1, 'k--', 'fL1', 'LabelVerticalAlignment', 'bottom');
xline(fR1, 'k--', 'fR1', 'LabelVerticalAlignment', 'bottom');
xline(fL2, 'k--', 'fL2', 'LabelVerticalAlignment', 'bottom');
xline(fR2, 'k--', 'fR2', 'LabelVerticalAlignment', 'bottom');

grid on;
title('Amplitude');
xlabel('Frequency [Hz]');
ylabel('Amplitude');
xlim([0, Fe/2]);

% Tracé du retard de groupe
subplot(2,1,2); hold on;
plot(f_retard, Retard_groupe, 'b', 'LineWidth', 1.5);
grid on;
title('Retard de groupe');
xlabel('Frequency [Hz]');
ylabel('Retard de groupe (échantillon)');
xlim([0, Fe/2]);
ylim([-2, 10]);
hold off;

%% Affichage des paramètres
disp(['Lvmax = ', num2str(Lvmax)]);
disp(['Lv1 = ', num2str(Lv1), ' ; Lv2 = ', num2str(Lv2)]);
disp(['fL1 = ', num2str(fL1), ' Hz ; fR1 = ', num2str(fR1), ' Hz']);
disp(['fL2 = ', num2str(fL2), ' Hz ; fR2 = ', num2str(fR2), ' Hz']);
disp(['p1 = ', num2str(p1), ' dB/dec.']);
disp(['p2 = ', num2str(p2), ' dB/dec.']);