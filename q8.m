clc;
clear;
close all;
%pkg load signal; % Pour GNU Octave

% Fenêtres d'apodisation :
% rectangulaire, triangulaire, Hann, Hamming, Blackman,
% Gaussienne, Welch, puissance de sinus, Flap-top, Tukey,
% Lanczos, Kaiser, Blackman–Harris,
% Blackman–Nuttall

%% Définition des fenêtres d'apodisation manquantes

function w = welchwin(n)
  m = floor(n/2); k = (0:m-1)';
  w = 1 - (2*k/n - 1).^2;
  if(mod(n, 2) ~= 0), w = [w; 1]; end
  w = [w; flipud(w(1:m, 1))];
end

function w = lanczoswin(n)
  w = sinc(2*[0:n-1]/(n-1)-1);
  w=w';
end

function w = sinepow(n,alpha)
  w = sin(pi*[0:n-1]/(n-1)).^alpha;
  w = w';
end

%% Fonctions permettant l'analyse des performances de fenêtres

function first_minimum_index = get_first_minimum_index (bins)
	prev_bin = bins(1);
	for i = 1:length(bins)
		current_bin = bins(i);

		if (current_bin > (prev_bin + 0.01))	% To prevent bug where 10.00 > 10.00 is considered true
			first_minimum_index = i;
			break;
		else
			prev_bin = current_bin;
        end
    end
end

function width_bin = get_first_lobe_width (bins)
	width_bin = 2 * get_first_minimum_index(bins);
end

function att_dB = get_secundary_lobe_attenuation (bins)
	first_minimum_index = get_first_minimum_index(bins);

	% Keep the data for the second to fourth lobe
	filtered_bins = bins(first_minimum_index:first_minimum_index*4);

	att_dB = max(filtered_bins);
end

function slope = get_Gibbs_slope (bins)    
	[peak_values, peak_indexes] = findpeaks(bins, 'NPeaks', 10);

    slope = (peak_values(7) - peak_values(6)) / (log2(peak_indexes(7)) - log2(peak_indexes(6)));
end


%% Calcul, tracé des graphiques, et évaluation des performances pour chaque fenêtre

% Paramètres
N=101;
NB=10240;

% Calcul des séquences échantillonnées des fenêtres d'apodisation
ff=[rectwin(N),triang(N),hann(N),hamming(N)];
ff=[ff,blackman(N),gausswin(N),welchwin(N),sinepow(N,4)];
ff=[ff,flattopwin(N),tukeywin(N),lanczoswin(N),kaiser(N)];
ff=[ff,blackmanharris(N),nuttallwin(N)];

winNames={'rectangulaire','triangulaire','Hann','Hamming','Blackman','Gaussienne','Welch','puissance de sinus','flat-top','Tukey','Lanczos','Kaiser','Blackman-Harris','Blackman-Nuttall'};

% 7 premières fenêtres
figure(1);clf;hold on;
for it=1:7
    w=ff(:,it);
    [f,W]= myResp(w,NB);

    % Tracé de la réponse impulsionnelle
    subplot(2,7,it);hold on;
	plot([0:N-1],w);
    title({'Réponse impulsionnelle de ',['"',winNames{it},'"']});

    % Tracé de la fonction de transfert
	bins = 20*log10(abs(W));
    subplot(2,7,7+it);hold on;
    plot(f, bins);
    title({'Fonction de transfert de ',['"',winNames{it},'"']});
    xlim([0,0.1]);

    % Affichage des performances de la fenêtre
    disp([newline winNames{it}, ' :']);

	disp(['First lobe width : ', num2str(get_first_lobe_width(bins) / N), ' bins / N']);
	disp(['Secundary lobe attenuation : ', num2str(get_secundary_lobe_attenuation(bins) - bins(1)), 'dB']);
    disp(['Gibbs zone slope : ', num2str(get_Gibbs_slope(bins)), 'dB/oct']);

end

% 7 dernières fenêtres
figure(2);clf;hold on;
for it=1:7
    w=ff(:,it+7);
    [f,W]= myResp(w,NB);

    % Tracé de la réponse impulsionnelle
    subplot(2,7,it);hold on;
	plot([0:N-1],w);
    title({'Réponse impulsionnelle de ',['"',winNames{it+7},'"']});

    % Tracé de la fonction de transfert
	bins = 20*log10(abs(W));
    subplot(2,7,7+it);hold on;
    plot(f, bins);
    title({'Fonction de transfert de ',['"',winNames{it+7},'"']});
    xlim([0,0.1]);

    % Affichage des performances de la fenêtre
    disp([newline winNames{it+7}, ' :']);

	disp(['First lobe width : ', num2str(get_first_lobe_width(bins) / N), ' bins / N']);
	disp(['Secundary lobe attenuation : ', num2str(get_secundary_lobe_attenuation(bins) - bins(1)), ' dB']);
    disp(['Gibbs zone slope : ', num2str(get_Gibbs_slope(bins)), 'dB/oct']);
end