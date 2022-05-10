clc; close all; clear all;
%%%%%%%%%%%%%%%%%% Sequence 3
% clc; close all; clear all;
% Constantes
V = 1;
nbit = 1000;
Fe = 24000;
Te = 1/Fe;
Rb = 3000;
Tb = 1/Rb;
Ns = Fe/Rb; % 8 ici
Ts = Ns*Te;

% Génération de bits
Tableau = randi([0,1],nbit,1);

%% 5.2)

RSB = 0.01;
% 1)
% Génération d'impulsions
Modulateur = (Tableau-0.5)*2;
Signal = [Modulateur' ; zeros(nbit,Ns-1)'];
Signal = Signal(:);

% Filtre de mise en forme
h = ones(Ns,1);
signal_filtre_e = filter(h,1,Signal); 
% Bruitage / Transmission
Px = mean(abs(signal_filtre_e).^2);
sigma = sqrt((Ns*Px)/2*RSB);
bruit = sigma * randn(1, length(signal_filtre_e));
% Réception
signal_int = signal_filtre_e + bruit';
signal_filtre_s = filter(h,1,signal_int);

Lt = 0:Te:(nbit*Ns-1)*Te;
plot(Lt,signal_filtre_s);
xlabel("temps (s)");
ylabel("Amplitude (V)");

figure,plot(reshape(signal_filtre_s,Ns,length(signal_filtre_s)/Ns));
eyediagram(signal_filtre_s(Ns:end),Ns);

signal_sortie = signal_filtre_s(Ns:Ns:end,1);
Demodulateur = signal_sortie > 0;
Erreur = mean((Tableau - Demodulateur) ~= 0);
% = 0


% 2)
vecteurTEB = zeros(9, 1);
bruit = randn(1, length(signal_filtre_e));
% Pour un rsb de 0dB le bruit est infiniment plus important que le signal
signal_int = bruit';
signal_filtre_s = filter(h,1,signal_int);
signal_sortie = signal_filtre_s(Ns:Ns:end,1);
Demodulateur = signal_sortie > 0;
vecteurTEB(1) = mean((Tableau - Demodulateur) ~= 0);

for i=2:9
    RSB = 1/10^(log10(i-1));
    sigma = sqrt((Ns*Px)/2*RSB);
    bruit = sigma * randn(1, length(signal_filtre_e));
    % Réception
    signal_int = signal_filtre_e + bruit';
    signal_filtre_s = filter(h,1,signal_int);
    signal_sortie = signal_filtre_s(Ns:Ns:end,1);
    Demodulateur = signal_sortie > 0;
    vecteurTEB(i) = mean((Tableau - Demodulateur) ~= 0);
end

% 3)
vecteurTEBth = qfunc(sqrt(2*(0:1:8)));
Ldb = 0:1:8;
figure, plot(Ldb,100*vecteurTEB);
hold on
plot(Ldb,100*vecteurTEBth);
hold off
xlabel("Rapport signal à bruit (dB)");
ylabel("Pourcentage %");
legend("Taux d'erreur binaire", "Taux d'erreur binaire théorique")


%% 5.3.1)
% 1)
% Génération d'impulsions
Modulateur = (Tableau-0.5)*2;
Signal = [Modulateur' ; zeros(nbit,Ns-1)'];
Signal = Signal(:);

% Filtre de mise en forme
h = ones(Ns,1);
signal_filtre_e = filter(h,1,Signal); 

hr = h;
hr(Ns/2+1:end) = 0;

signal_filtre_s = filter(hr,1,signal_filtre_e);

Lt = 0:Te:(nbit*Ns-1)*Te;
figure, plot(Lt,signal_filtre_s);
xlabel("temps (s)");
ylabel("Amplitude (V)");

eyediagram(signal_filtre_s(Ns:end),Ns);
% N0 = Ts/2

% 2)
signal_sortie = signal_filtre_s(Ns/2:Ns:end,1);
Demodulateur = signal_sortie > 0;
Erreur2 = mean((Tableau - Demodulateur) ~= 0);
% Erreur2 = 0

%% 5.3.2)

% 1)

% Génération d'impulsions
Modulateur = (Tableau-0.5)*2;
Signal = [Modulateur' ; zeros(nbit,Ns-1)'];
Signal = Signal(:);

% Filtre de mise en forme
h = ones(Ns,1);
signal_filtre_e = filter(h,1,Signal);
hr = h;
hr(Ns/2+1:end) = 0;
% Bruitage / Transmission
Px = mean(abs(signal_filtre_e).^2);
for i=2:10:32
    RSB = 1/10^(log10(i-1));
    sigma = sqrt((Ns*Px)/2*RSB);
    bruit = sigma * randn(1, length(signal_filtre_e));
    % Réception
    signal_int = signal_filtre_e + bruit';
    signal_filtre_s = filter(hr,1,signal_int);
    eyediagram(signal_filtre_s(Ns:end),Ns);
end

% 2) et 3)
vecteurTEB2 = zeros(9, 1);
bruit = randn(1, length(signal_filtre_e));
% Pour un rsb de 0dB le bruit est infiniment plus important que le signal
signal_int = bruit';
signal_filtre_s = filter(hr,1,signal_int);
signal_sortie = signal_filtre_s(Ns/2:Ns:end,1);
Demodulateur = signal_sortie > 0;
vecteurTEB2(1) = mean((Tableau - Demodulateur) ~= 0);

for i=2:9
    RSB = 1/10^(log10(i-1));
    sigma = sqrt((Ns*Px)/2*RSB);
    bruit = sigma * randn(1, length(signal_filtre_e));
    % Réception
    signal_int = signal_filtre_e + bruit';
    signal_filtre_s = filter(hr,1,signal_int);
    signal_sortie = signal_filtre_s(Ns/2:Ns:end,1);
    Demodulateur = signal_sortie > 0;
    vecteurTEB2(i) = mean((Tableau - Demodulateur) ~= 0);
end

Ldb = 0:1:8;
vecteurTEBth2 = qfunc(sqrt(0:1:8));
figure, semilogy(Ldb,100*vecteurTEB2);
hold on
semilogy(Ldb,100*vecteurTEBth2);
hold off
xlabel("Rapport signal à bruit (dB)");
ylabel("Pourcentage %");
legend("Taux d'erreur binaire", "Taux d'erreur binaire théorique")

% 4)


%% 5.5)
bits = Tableau;
% Mapping
Sig = (2 * bi2de(reshape(bits, 2, length(bits)/2).') - 3).';
Signal = [Sig ; zeros(nbit/2,Ns-1)'];
Signal = Signal(:);


% Filtre de mise en forme
h = ones(Ns,1);
signal_filtre_e = filter(h,1,Signal);
signal_filtre_s = filter(h,1,signal_filtre_e);

Lt = 0:Te:((nbit/2)*Ns-1)*Te;
figure, plot(Lt,signal_filtre_s);
xlabel("temps (s)");
ylabel("Amplitude (V)");

eyediagram(signal_filtre_s(Ns:end),Ns);
% N0 = Ns

% Demapping
signal_sortie = signal_filtre_s(Ns:Ns:end,1);
Demodulateur = (-3 * (signal_sortie <= -16)) + (-1 * (((signal_sortie > -16) + (signal_sortie < 0)) > 1)) + (((signal_sortie >= 0) + (signal_sortie < 16)) > 1) + (3 * (signal_sortie >= 16));
BitsDecides = reshape(de2bi((Demodulateur + 3)/2).', 1, length(bits))';
Erreur3 = mean((bits - BitsDecides) ~= 0);


%% 5.6)

%% Iterer correctement sur vecteur, qfunc pas en dB : 10.^(0.1*(0:1:8))
%% 5.3.2) 4) et 5) à faire

% 1) et 3)
vecteurTES = zeros(9, 1);
vecteurTEB3 = zeros(9, 1);
bruit = randn(1, length(signal_filtre_e));
% Pour un rsb de 0dB le bruit est infiniment plus important que le signal
signal_int = bruit';
signal_filtre_s = filter(h,1,signal_int);
signal_sortie = signal_filtre_s(Ns:Ns:end,1);
Demodulateur = (-3 * (signal_sortie <= -16)) + (-1 * (((signal_sortie > -16) + (signal_sortie < 0)) > 1)) + (((signal_sortie >= 0) + (signal_sortie < 16)) > 1) + (3 * (signal_sortie >= 16));
vecteurTES(1) = mean((Sig' - Demodulateur) ~= 0);
BitsDecides = reshape(de2bi((Demodulateur + 3)/2).', 1, length(bits))';
vecteurTEB3(1) = mean((bits - BitsDecides) ~= 0);

for i=2:9
    RSB = 1/10^(log10(i-1));
    sigma = sqrt((Ns*Px)/2*RSB);
    bruit = sigma * randn(1, length(signal_filtre_e));
    % Réception
    signal_int = signal_filtre_e + bruit';
    signal_filtre_s = filter(h,1,signal_int);
    signal_sortie = signal_filtre_s(Ns:Ns:end,1);
    Demodulateur = (-3 * (signal_sortie <= -16)) + (-1 * (((signal_sortie > -16) + (signal_sortie < 0)) > 1)) + (((signal_sortie >= 0) + (signal_sortie < 16)) > 1) + (3 * (signal_sortie >= 16));
    vecteurTES(i) = mean((Sig' - Demodulateur) ~= 0);
    BitsDecides = reshape(de2bi((Demodulateur + 3)/2).', 1, length(bits))';
    vecteurTEB3(i) = mean((bits - BitsDecides) ~= 0);
end

Ldb = 0:1:8;
figure, plot(Ldb,100*vecteurTES);
xlabel("Rapport signal à bruit (dB)");
ylabel("Pourcentage %");
legend("Taux d'erreur symbole");

% 2)
Ldb = 0:1:8;
vecteurTESth = 3/2 * qfunc(sqrt(4/5 *(0:1:8)));
figure, plot(Ldb,100*vecteurTES);
hold on
plot(Ldb,100*vecteurTESth);
hold off
xlabel("Rapport signal à bruit (dB)");
ylabel("Pourcentage %");
legend("Taux d'erreur symbole","Taux d'erreur symbole théorique");

% 3)
Ldb = 0:1:8;
figure, plot(Ldb,100*vecteurTEB3);
xlabel("Rapport signal à bruit (dB)");
ylabel("Pourcentage %");
legend("Taux d'erreur binaire");

% 4)
Ldb = 0:1:8;
vecteurTEBth = 3/4 * qfunc(sqrt(4/5 *(0:1:8)));
figure, plot(Ldb,100*vecteurTEB3);
hold on
plot(Ldb,100*vecteurTEBth);
hold off
xlabel("Rapport signal à bruit (dB)");
ylabel("Pourcentage %");
legend("Taux d'erreur binaire","Taux d'erreur binaire théorique");

% 5)
Ldb = 0:1:8;
figure, plot(Ldb,100*vecteurTEB2);
hold on
plot(Ldb,100*vecteurTEB3);
hold off
xlabel("Rapport signal à bruit (dB)");
ylabel("Pourcentage %");
legend("Taux d'erreur binaire de la chaine de référence","Taux d'erreur binaire de la chaine implantée");
% Chainé implémentée plus efficace car avec le mapping 4-aire, même taux
% d'erreur symbole que mapping 2-aire mais taux d'erreur binaire /2 car
% quand on se trompe de symbole on a quand même 1 bit /2 de bon en général

%6)
% Chaine de référence, spectre = sinus cardinal 
% Chaine implanté aussi sinus cardinal mais nb de symboles /2 car 2 bits
% par symbole donc Tb/2 et donc Rb * 2 alors que la bande passant B reste
% la même
% efficacité spectrale n = Rb/B 
% --> efficacité 2* meilleure






