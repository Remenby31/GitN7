clc; close all; clear all;
% ==== Sequence 1 ====

% ---- Constantes ----

Fe = 24000;
Rb = 3000;
nbr_bits = 3000; % Nombre de bits générés
Ns = Fe/Rb; % Durée symbole en nombre d+échantillons (Ts=NsTe)
V = 1;
Lf = linspace(-Fe/2,Fe/2,24000);
alpha = 0.8;
Ts = Ns/Fe;

% ---- Generation Bits ----

Bits = randi([0,1],nbr_bits,1); %Génération de l’information binaire

%% ---- Modulateur 1 ----

    % Generation Impulsion

Bits1 = (Bits-0.5)*2;
Imp1 = [Bits1' ; zeros(nbr_bits,Ns-1)'];
Imp1 = Imp1(:);

    % Filtre mise en forme

h = ones(Ns,1); % Filtre de mise en forme
Mod1_Filtre = filter(h,1,Imp1);

    % DSP

dsp1 = fftshift(abs(fft(Mod1_Filtre)));
dsp1T = Ts * (sinc(Lf*Ts)).^2;

%% ---- Modulateur 2 ----

% Generation Impulsion

Imp2 = [];
for i = 1:(length(Bits)/2)
    b = string(Bits(i)) + string(Bits(i+1));
    if b == "00"
        Imp2 = [Imp2 3*V];
    elseif b == "01"
        Imp2 = [Imp2 V];
    elseif b == "10"
        Imp2 = [Imp2 -V];
    else
        Imp2 = [Imp2 -3*V];
    end

    for k = 1:(2 * Ns - 1)
        Imp2 = [Imp2 0];
    end
end

    % Filtre mise en forme

h2 = ones(2*Ns,1); % Filtre de mise en forme
Imp2_Filtre = filter(h2,1,Imp2);

    % DSP

dsp2 = fftshift(abs(fft(Imp2_Filtre)));
dsp2T = 2.*dsp1T;

%% ---- Modulateur 3 ----

Imp3 = Imp1; % Memes impulsions que le modulateur 1

h3 = rcosdesign(0.5, 8, Ns); % Filtre de mise en forme du modulateur 3 (racine de cosinus sur´elevé)
Mod3_Filtre = filter(h3, 1, Imp3);

    % DSP

dsp3 = fftshift(abs(fft(Mod3_Filtre)));

A = 1/2 .* (1 + cos(pi*Ts/alpha*(abs(Lf)-(1-alpha)/(2*Ts))));
dsp3T = 0.25 .* (ones(size(Lf)) .* ( (1-alpha)/(2*Ts) >= abs(Lf) ) + A .* ( ((1-alpha)/(2*Ts) <= abs(Lf)) & ((1+alpha)/(2*Ts) >= abs(Lf)) ));


% ---- Affichage ----

% Signaux
plot(linspace(0,1/Fe * length(Mod1_Filtre),length(Mod1_Filtre)),Mod1_Filtre,linspace(0,1/Fe * length(Imp2_Filtre),length(Imp2_Filtre)),Imp2_Filtre,linspace(0,1/Fe * length(Mod3_Filtre),length(Mod3_Filtre)),Mod3_Filtre);
title("Modulations");
legend("1","2","3");
xlabel("Temps (s)");
ylabel("Amplitude (V)");

% DSP simulés
semilogy(linspace(-Fe/2,Fe/2,length(dsp1)),dsp1',linspace(-Fe/2,Fe/2,length(dsp2)),dsp2',linspace(-Fe/2,Fe/2,length(dsp3)),dsp3');
title("DSP");
ylim([1 10^4]);
xlim([-1.2*10^4 1.2*10^4])
legend("DSP Modulateur 1","DSP Modulateur 2","DSP Modulateur 3");
xlabel("Frequence (f)");
ylabel("Amplitude (V)");

% DSP Théoriques
semilogy(Lf,dsp1T,Lf,dsp2T,Lf,dsp3T);
title("DSP Théorique");
legend("1","2","3");
xlabel("Frequence (f)");
ylabel("Amplitude (V)");

% Comparaison1,

semilogy(Lf,dsp1T,Lf,dsp1);
title("Comparaison DSP 1");
legend("théorique","réél");
xlabel("Frequence (f)");
ylabel("Amplitude (V)");

% Comparaison2

semilogy(Lf,dsp2T,Lf,dsp2);
title("Comparaison DSP 2");
legend("théorique","réél");
xlabel("Frequence (f)");
ylabel("Amplitude (V)");

% Comparaison3

semilogy(Lf,dsp3T,Lf,dsp3);
title("Comparaison DSP 3");
legend("théorique","réél");
xlabel("Frequence (f)");
ylabel("Amplitude (V)");


%% ==== Sequence 2 ====
hr = ones(Ns,1); % filtre de reception

% Reponse impulsionnelle de la chaine [Filtre mise en forme + Filtre reception]
z = zeros(size(hr));
h1 = [h; z];
hr = [h; z];
ImpChaine = conv(h1,hr);

plot(linspace(0,1/8000,length(h1)), h1, linspace(0,1/8000,length(ImpChaine)), ImpChaine);
title("Reponse impulsionnelle de la chaine (convolution)");
ylabel("Amplitude (V)");
xlabel("temps (t)");
legend("h","convolution");


%% ==== Sequence 3 ====

x = filter(h,1,Imp1); % Mise en forme du signal x

Px = mean(abs(x).^2); % Puissance du Signal à bruiter
M = 2; % Ordre de la modulation
rapportSigBruit = 10; % rapport signal / bruit par bit à l'entrée du récepteur en Db

% Génération du Bruit Gaussien
bruit = sqrt(Px*Ns/(2*log2(M)*10^(rapportSigBruit/10))) * randn(1, length(x));

% Chaine de référence
Fe = 24000; % Fréquence d'échantillonage
Rb = 3000; % Débit Binaire
ordre = 8; % Ordre des deux filtres cumulés



yb = x + bruit; % Avec Bruit
yb = x; % Sans Bruit
yb = filter(hr,1,yb); % Filtre en réception (symétrique du filtre de modulation)
eyediagram(yb(Ns:end),Ns);

% Affichage du signal avant et apres le canal (Bruit + Filtre Reception)
plot(linspace(0,1/8000,length(yb)),yb,linspace(0,1/8000,length(x)),x.*10);
title("yb & x");
legend("yb","x");
ylabel("Amplitude (V)");

% 2. Calcul du taux d'erreur binaire en fonction du rapport signal bruit

Lbruit = linspace(0,8,20); % Abscisse (bruit du signal) (db)
Ltb = []; % Ordonée (taux d'erreur binaire) (%)

for i = 1:length(Lbruit)
    
    % - Creation du signal -
    bruit = sqrt(Px*Ns/(2*log2(M)*10^(i/10))) * randn(1, length(x));
    yb = x + bruit'; % ajouter le bruit
    yb = filter(hr,1,yb); % Filtre en réception (symétrique du filtre de modulation)
    
    % - Calcul du taux binaire -
    ybBin = yb(Ns:Ns:end);
    ybBin = (ybBin > 0);
    tauxBinaire = sum((Bits ~= ybBin))/length(Bits)*100;

    % - Ajout du taux binaire à l'ordonée
    Ltb = [Ltb tauxBinaire];
end

% Affichage du TEB en fonction du rapport signal bruit
plot(Lbruit, Ltb);
title("Taux d’erreur binaire obtenu en fonction du rapport signal bruit");
xlabel("Rapport signal bruit");
ylabel("Taux d'erreur binaire");
figure;
% Attente théorique ?

% 5.3

