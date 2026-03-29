clear; close all;
%pkg load signal; % Pour GNU Octave

% Paramètres du filtre
Fc = 250; % Fréquence de coupure en Hz
Fe = 2000; % Fréquence d'échantillonnage en Hz
wc = 2*pi*Fc/Fe; % Fréquence normalisée

%% Réponse impulsionnelle en fonction du nombre de points

% Différentes valeurs de N
N_values = [16, 51, 101];
% N_values = [50];
colors = ['r', 'g', 'b', 'k']; % Couleurs pour chaque courbe

figure(1); clf;hold on;
for i = 1:length(N_values)
    N = N_values(i);
    n = -N/2:N/2-1;
    h = 2*Fc/Fe*sinc(2*n*Fc/Fe);
    stem(n, h, 'DisplayName', ['N = ' num2str(N)]);
end
legend
grid on;
title('Réponse impulsionnelle échantillonnée d''un filtre passe-bas');
xlabel('Numéro d''échantillon');
ylabel('Amplitude');
hold off;

%% Spectre fréquentiel (amplitude et phase) en fonction du nombre de points

figure(2); clf;
for i = 1:length(N_values)
    N = N_values(i);
    NB = N*20;
    if mod(N,2)==0
        n=-N/2:N/2-1;
    else
        n=-(N-1)/2:(N-1)/2-1;
    end
    h = 2*Fc/Fe*sinc(2*n*Fc/Fe);
    H = fft(h, NB);
    wc = linspace(0, 1, NB);
    f = wc*Fe;

    % Amplitude
    subplot(2,length(N_values),i);hold on;
	plot(f, abs(H), 'linewidth', 2, 'DisplayName', ['N = ' num2str(N)]);
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
    xlim([0,Fe/2]);
    legend
    grid on;
    hold off;

    % Délai de groupe
    subplot(2,length(N_values),i+length(N_values));hold on;
    % plot(f, unwrap(angle(H)));xlim([0,Fe/2]);
    plot(f(2:end), -diff(unwrap(angle(H)))/(2*pi*Fe), 'linewidth', 2, 'DisplayName', ['N = ' num2str(N)]);
    xlabel('Frequency (Hz)');
    ylabel('Délai de groupe (s)');
	%xlim([0,Fc]);
    xlim([0,Fe/2]);
    ylim([-3,3]*1e-4);
    legend
    grid on;
    hold off;
end
