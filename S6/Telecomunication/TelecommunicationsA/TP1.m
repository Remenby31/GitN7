clc; close all; clear all;
%%%%%%%%%%%%%%%%%% Sequence 1
% Constantes
V = 1;
nbit = 100;
Fe = 24000;
Te = 1/Fe;
Rb = 3000;
Tb = 1/Rb;
Ns = Fe/Rb;
Ts = Ns*Te;
% Génération de bits
Tableau = randi([0,1],nbit,1);

%% Modulateur 1

% Génération d'impulsions
Bits1 = (Tableau-0.5)*2;
Signal1 = [Bits1' ; zeros(nbit,Ns-1)'];
Signal1 = Signal1(:);

plot(Bits1);
label("Modulateur 1");

% Filtre de mise en forme
h = ones(Ns,1);
signal_filtre1 = filter(h,1,Signal1);

% Représentation graphique temporelle

Lt = 0:Te:(nbit*Ns-1)*Te;
plot(Lt,signal_filtre1);
xlabel("temps (s)");
ylabel("Amplitude (V)");

% Dsp et Dsp théorique
Dsp1 = fftshift(abs(fft(signal_filtre1)));
F = linspace(-Fe/2,Fe/2,Ns*nbit);
Dspth1 = Ts*(sinc(F*Ts).^2);
figure,semilogy(F,Dsp1,'b',F,Dspth1,'r');
legend('Dsp','Dsp Théorique');
xlabel("Fréquence (Hz)");
ylabel("Amplitude (V)");



%% Modulateur 2

% Génération d'impulsions
Bits2 = [];
for i=1:2:nbit
    if Tableau(i) == 0
        if Tableau(i+1) == 0
            Bits2((i+1)/2) = -3*V;
        else
            Bits2((i+1)/2) = -V;
        end
    else
        if Tableau(i+1) == 0
            Bits2((i+1)/2) = 3*V;
        else
            Bits2((i+1)/2) = V;
        end
    end
end
Signal2 = [Bits2 ; zeros(nbit/2,2*Ns-1)'];
Signal2 = Signal2(:);

% Filtre de mise en forme
h = ones(2*Ns,1);
signal_filtre2 = filter(h,1,Signal2)

% Représentation graphique temporelle

Lt = 0:Te:(nbit*Ns-1)*Te;
figure,plot(Lt,signal_filtre2);
xlabel("temps (s)");
ylabel("Amplitude (V)");

% Dsp et Dsp théorique
Dsp2 = fftshift(abs(fft(signal_filtre2)));
F = linspace(-Fe/2,Fe/2,Ns*nbit);
Dspth2 = 2*Dspth1
figure,semilogy(F,Dsp2,'b',F,Dspth2,'r');
legend('Dsp','Dsp Théorique');
xlabel("Fréquence (Hz)");
ylabel("Amplitude (V)");

%% Modulateur 3

% Génération d'impulsions
Signal3 = Signal1;

% Filtre de mise en forme
hcos = rcosdesign(0.5, 20, Ns);
signal_filtre3 = filter(hcos,1,Signal3);

% Représentation graphique temporelle

Lt = 0:Te:(nbit*Ns-1)*Te;
figure,plot(Lt,signal_filtre3);
xlabel("temps (s)");
ylabel("Amplitude (V)");

% Dsp et Dsp théorique
Dsp3 = fftshift(abs(fft(signal_filtre3)));
F = linspace(-Fe/2,Fe/2,Ns*nbit);
Dspth3 = 0.25.*((abs(F)<=(1/(4*Ts))) + ((abs(F)<=(3/(4*Ts)) & abs(F)>=(1/(4*Ts)))).*((1+cos(pi*Ts*2*(abs(F)-(1/(4*Ts)))))/2));
%Dspth3 = zeros(Ns*nbit,1);
figure,semilogy(F,Dsp3,'b',F,Dspth3,'r');
legend('Dsp','Dsp Théorique');
xlabel("Fréquence (Hz)");
ylabel("Amplitude (V)");

%% Question 3
figure,semilogy(F,Dsp1,'k',F,Dsp2,'r',F,Dsp3,'b');
legend('Dsp Modulateur 1','Dsp Modulateur 2','Dsp Modulateur 3');
ylim([1,5*10^3]);
xlabel("Fréquence (Hz)");
ylabel("Amplitude (V)");








