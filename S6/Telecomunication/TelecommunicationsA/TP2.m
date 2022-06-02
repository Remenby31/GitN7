clc; close all; clear all;
%%%%%%%%%%%%%%%%%% Sequence 2
% clc; close all; clear all;
% Constantes
V = 1;
nbit = 100;
Fe = 24000;
Te = 1/Fe;
Rb = 3000;
Tb = 1/Rb;
Ns = Fe/Rb; % 8 ici
Ts = Ns*Te;

% Génération de bits
Tableau = randi([0,1],nbit,1);

%% 4.2)

% 1)
% Génération d'impulsions
Modulateur = (Tableau-0.5)*2;
Signal = [Modulateur' ; zeros(nbit,Ns-1)'];
Signal = Signal(:);

% Filtre de mise en forme
h = ones(Ns,1);
signal_filtre_e = filter(h,1,Signal);
% Réception
signal_filtre_s = filter(h,1,signal_filtre_e);

% 2)
Lt = 0:Te:(nbit*Ns-1)*Te;
plot(Lt,signal_filtre_s);
xlabel("temps (s)");
ylabel("Amplitude (V)");

% 3)
g = [0 ; conv(h,h) ; 0];
Lt = 0:Te:2*Ts;
figure,plot(Lt,g);
title("conv")
xlabel("temps (s)");
ylabel("Amplitude (V)");

% 4) 
% n0 = Ns = 8 ici c'est à dire au bout de t = Ts

% 5)
figure,plot(reshape(signal_filtre_s,Ns,length(signal_filtre_s)/Ns));
eyediagram(signal_filtre_s(Ns:end),Ns);

% 6)
% Oui on retrouve bien qu'à Ts on a toujours 1 ou -1 

% 7)
signal_sortie = signal_filtre_s(Ns:Ns:end,1);
Demodulateur = signal_sortie > 0;
Erreur = mean((Tableau - Demodulateur) ~= 0);
% = 0

% 8)
signal_sortie2 = signal_filtre_s(3:Ns:end,1);
Demodulateur2 = signal_sortie2 > 0;
Erreur2 = mean((Tableau - Demodulateur2) ~= 0);
% environ = 0.5

%% 4.3)
% 1)
% paramètres
Fc = 8000;
N = 81;
% 1.
hc = (2 * Fc/Fe) * sinc(2 * (Fc/Fe) * [-(N - 1)/2 : 1 : (N - 1)/2]);
newg = conv(hc, g);
newN = length(newg);
figure,plot([-(newN - 1)/2 : 1 : (newN - 1)/2],newg);

% 2.
Signal_decal = [Signal ; zeros((N+1)/2,1)];
signal_transmit = filter(newg,1,Signal_decal);
signal_transmit = signal_transmit((N+1)/2+1:end);
figure, plot(signal_transmit);
figure, plot(reshape(signal_transmit,Ns,length(signal_transmit)/Ns));

% 3.
n_fft = 512;
fft_g = abs(fft(g,n_fft));
fft_hc = abs(fft(hc,n_fft));
figure , semilogy(linspace(0, Fe, n_fft),fft_g)
hold on
semilogy(linspace(0, Fe, n_fft),fft_hc)
hold off
legend("|H(f)Hr(f)|", "|Hc(f)|")

% 4.
signal_sortie3 = signal_transmit(8:Ns:end,1);
Demodulateur3 = signal_sortie3 > 0;
Erreur3 = mean((Tableau - Demodulateur3) ~= 0); 

% 2)
% paramètres
Fc = 1000;
N = 81;
% 1.
hc = (2 * Fc/Fe) * sinc(2 * (Fc/Fe) * [-(N - 1)/2 : 1 : (N - 1)/2]);
newg = conv(hc, g);
newN = length(newg);
figure, plot([-(newN - 1)/2 : 1 : (newN - 1)/2],newg);

% 2.
Signal_decal = [Signal ; zeros((N+1)/2,1)];
signal_transmit = filter(newg,1,Signal_decal);
signal_transmit = signal_transmit((N+1)/2+1:end);
figure, plot(signal_transmit);
figure, plot(reshape(signal_transmit,Ns,length(signal_transmit)/Ns));

% 3.
n_fft = 512;
fft_g = abs(fft(g,n_fft));
fft_hc = abs(fft(hc,n_fft));
figure , semilogy(linspace(0, Fe, n_fft),fft_g)
hold on
semilogy(linspace(0, Fe, n_fft),fft_hc)
hold off
legend("|H(f)Hr(f)|", "|Hc(f)|")

% 4.
signal_sortie4 = signal_transmit(8:Ns:end,1);
Demodulateur4 = signal_sortie4 > 0;
Erreur4 = mean((Tableau - Demodulateur4) ~= 0);
% ~ 0.1 
% Fc trop petit, on garde la majorité de l'information mais on en perd
% quand meme une trop grande partie















