clc;
clear;
close all;
%pkg load signal; % Pour GNU Octave

% Paramètres
Fe = 1000;  % Hz
A1 = 1;     % Amplitude f1
f1 = 12.5;    % Hz
A2 = 0.6;     % Amplitude f2
f2 = 50;    % Hz
A3 = 0.4;     % Amplitude f3
f3 = 110.1;   % Hz
duree_signal = 1;   % sec

t = 0:1/Fe:(duree_signal - 1/Fe);
N = length(t);

%% Signal polychromatique
signal = A1 .* sin(2 .* pi .* f1 .* t) + A2 .* sin(2 .* pi .* f2 .* t) + A3 .* sin(2 .* pi .* f3 .* t);

figure(1)
subplot(2,1,1);
plot(t, signal);
title('Signal polychromatique transitoire');
xlabel('Temps (s)');
ylabel('Amplitude');

fft_signal = fft(signal);
f = Fe .* linspace(0, 1, N);

subplot(2,1,2);
plot(f, 20*log10(abs(fft_signal) .*2 ./ N));
title('Spectre fréquentiel du signal polychromatique transitoire');
xlabel('Fréquence (Hz)');
ylabel('Amplitude (dB)');
xlim([0 120]);

%% Application des fenêtres d'apodisation
windows = [rectwin(N), flattopwin(N), tukeywin(N), blackmanharris(N)];
windows_name = {'rectangulaire', 'Flat-top', 'Tukey', 'Blackman-Harris'};

figure(2);
for i = 1:4
    signal_apodise = signal .* windows(:, i)';
    subplot(2, 4, i);
    plot(t, signal_apodise);
    title(['Signal apodisé avec la fenêtre ' windows_name{i}]);
    xlabel('temps (s)');
    ylabel('Amplitude');
       
    subplot(2, 4, i + 4);
    plot(f, 20*log10(abs(fft(signal_apodise)) .* 2 ./ sum(windows(:, i))));
    title(['Spectre fréquentiel du signal apodisé avec' newline 'la fenêtre ' windows_name{i}]);
    xlabel('Fréquence (Hz)');
    ylabel('Amplitude (dB)');
    xlim([0 120]);
    ylim([-150 0]);
end