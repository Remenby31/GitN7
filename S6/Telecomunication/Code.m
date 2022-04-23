clc; close all; clear all;
% ==== Sequence 1 ====

% ---- Constantes ----

Fe = 24000;
Rb = 3000;
nbr_bits = 3000;
nbr_bits_par_symbole = Fe/Rb;
V = 1;
Lf = linspace(-Fe/2,Fe/2,24000);
alpha = 0.8;
Ts = nbr_bits_par_symbole/Fe;

% ---- Generation Bits ----

Bits = randi([0,1],1,nbr_bits);

% ---- Modulateur 1 ----

    % Generation Impulsion
Mod1 = [];
for i = 1:length(Bits)
    if Bits(i) == 1
        symbole = V;
    else
        symbole = -V;
    end
    Mod1 = [Mod1,0];
    
    for k = 1:(nbr_bits_par_symbole - 1)
        Mod1 = [Mod1,symbole];
    end
end

    % Filtre mise en forme

hr = ones(nbr_bits_par_symbole,1);
Mod1_Filtre = filter(hr,1,Mod1);

    % DSP
dsp1 = fftshift(abs(fft(Mod1_Filtre)));
dsp1T = Ts * (sinc(Lf*Ts)).^2;

% ---- Modulateur 2 ----

Mod2 = [];
for i = 1:(length(Bits)/2)
    b = string(Bits(i)) + string(Bits(i+1));
    if b == "00"
        Mod2 = [Mod2 3*V];
    elseif b == "01"
        Mod2 = [Mod2 V];
    elseif b == "10"
        Mod2 = [Mod2 -V];
    else
        Mod2 = [Mod2 -3*V];
    end

    for k = 1:(2 * nbr_bits_par_symbole - 1)
        Mod2 = [Mod2 0];
    end
end

    % Filtre mise en forme

hr2 = ones(2*nbr_bits_par_symbole,1);
Mod2_Filtre = filter(hr2,1,Mod2);

    % DSP

dsp2 = fftshift(abs(fft(Mod2_Filtre)));
dsp2T = 2.*dsp1T;

% ---- Modulateur 3 ----

Mod3 = Mod1(:);

hr3 = rcosdesign(0.5, 8, nbr_bits_par_symbole);
Mod3_Filtre = filter(hr3,1,Mod3);

    % DSP

dsp3 = fftshift(abs(fft(Mod3_Filtre)));

A = 1/2 .* (1 + cos(pi*Ts/alpha*(abs(Lf)-(1-alpha)/(2*Ts))));
dsp3T = 0.25 .* (ones(size(Lf)) .* ( (1-alpha)/(2*Ts) >= abs(Lf) ) + A .* ( ((1-alpha)/(2*Ts) <= abs(Lf)) & ((1+alpha)/(2*Ts) >= abs(Lf)) ));


% ---- Affichage ----

plot(linspace(0,1/Fe * length(Mod1_Filtre),length(Mod1_Filtre)),Mod1_Filtre,linspace(0,1/Fe * length(Mod2_Filtre),length(Mod2_Filtre)),Mod2_Filtre,linspace(0,1/Fe * length(Mod3_Filtre),length(Mod3_Filtre)),Mod3_Filtre);
title("Modulations");
legend("1","2","3");
xlabel("Temps (s)");
ylabel("Amplitude (V)");
%figure;

semilogy(linspace(-Fe/2,Fe/2,length(dsp1)),dsp1',linspace(-Fe/2,Fe/2,length(dsp2)),dsp2',linspace(-Fe/2,Fe/2,length(dsp3)),dsp3');
title("DSP");
legend("1","2","3");
xlabel("Frequence (f)");
ylabel("Amplitude (V)");

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
%figure;

% Comparaison2

semilogy(Lf,dsp2T,Lf,dsp2);
title("Comparaison DSP 2");
legend("théorique","réél");
xlabel("Frequence (f)");
ylabel("Amplitude (V)");
%figure;

% Comparaison3

semilogy(Lf,dsp3T,Lf,dsp3);
title("Comparaison DSP 3");
legend("théorique","réél");
xlabel("Frequence (f)");
ylabel("Amplitude (V)");


% ==== Sequence 2 ====

% ---- Generation Bits ----

Bits = randi([0,1],1,nbr_bits);


% ---- Modulateur ----


Mod1 = [];
for i = 1:length(Bits)
    if Bits(i) == 1
        symbole = V;
    else
        symbole = -V;
    end
    for k = 1:(nbr_bits_par_symbole)
        Mod1 = [Mod1,symbole];
    end
end



% ==== Sequence 3 ====

x = Mod1;
Px = mean(abs(x).^2); % Puissance du Signal à bruiter
Ns = nbr_bits_par_symbole; % le facteur de sur ́echantillonage
M = 2; % Ordre de la modulation
rapportSigBruit = 10; % rapport signal / bruit par bit à l'entrée du récepteur en Db

% Bruit Gaussien
bruit = sqrt(Px*Ns/(2*log2(M)*10^(rapportSigBruit/10))) * randn(1, length(x));

% Chaine de référence
Fe = 24000; % Fréquence d'échantillonage
Rb = 3000; % Débit Binaire
ordre = 8; % Ordre des deux filtres cumulés
hr = ones(nbr_bits_par_symbole,1); % filtre


yb = x + bruit; % Avec Bruit
yb = filter(hr,1,yb); % Filtre en réception (symétrique du filtre de modulation)
eyediagram(yb(nbr_bits_par_symbole:end),nbr_bits_par_symbole);
figure;


plot(linspace(0,length(yb),length(yb)),yb,linspace(0,length(x),length(x)),x.*10);
title("yb & x");
legend("yb","x");
ylabel("Amplitude (V)");
figure;

% 2. Calcul du taux d'erreur binaire en fonction du rapport signal bruit

Lbruit = linspace(0,8,20); % Abscisse (bruit du signal) (db)
Ltb = []; % Ordonée (taux d'erreur binaire) (%)

for i = 1:length(Lbruit)
    
    % - Creation du signal -
    bruit = sqrt(Px*Ns/(2*log2(M)*10^(i/10))) * randn(1, length(x));
    yb = x + bruit; % ajouter le bruit
    yb = filter(hr,1,yb); % Filtre en réception (symétrique du filtre de modulation)
    
    % - Calcul du taux binaire -
    ybBin = yb(nbr_bits_par_symbole:nbr_bits_par_symbole:end);
    ybBin = (ybBin > 0);
    tauxBinaire = sum((Bits ~= ybBin))/length(Bits)*100;

    % - Ajout du taux binaire à l'ordonée
    Ltb = [Ltb tauxBinaire];
end

plot(Lbruit, Ltb);
title("Taux d’erreur binaire obtenu en fonction du rapport signal bruit");
xlabel("Rapport signal bruit");
ylabel("Taux d'erreur binaire");

% Attente théorique ?

% 5.3

