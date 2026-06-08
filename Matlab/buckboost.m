
%% ═══════════════════════════════════════════════════════════
%  stability Analysis
%  Inverting Buck-Boost PCMC
%  Engineer: Mohamed Drissi
%% ═══════════════════════════════════════════════════════════
%%  Converter Operating Point
% 
clear; clc; close all;
Vdc = 24;
Vout = 12;
Iout = 3;
fs = 300e3; %switching freq
D=  Vout/(Vdc+Vout) %Duty cycle
D1=1-D;
R = Vout / Iout;  %Load
L = 22e-6; %induCtor 
C = 78.8e-6; %Output capacitor
Ri = 0.3;  %Shunt resistor 
rc = 0.002; %CAPACITOR ESR


% Vdc = 40;
% Vout = 12;
% Iout = 1.5;
% fs = 100e3; %switching freq
% D=  Vout/(Vdc+Vout) %Duty cycle
% D1=1-D;
% R = Vout / Iout;  %Load
% L = 250e-6; %induCtor 
% C = 470e-6; %Output capacitor
% Ri = 0.5;  %Shunt resistor 
% rc = 0.07; %CAPACITOR ESR
% 

Vref = 1.215;  %¨reference voltage
Tsw=1/fs ;

R4= 1.13e3;    %feedback resistors 
R5= 10e3;

%% Aux external ramp

Sn = ((Vdc)/L)*Ri;
Sf = ((Vout) / L)*Ri; 
Se = 90000;  %external compensating ramp  

mc = 1 + (Se/Sn);

%% TF parameters
wz1 = 1/(rc*C);

wz2 = ((D1^2)*R)/(D*L);

Tau = (L/R)*fs;

M = Vout/Vdc;

Ho= (R/Ri)*1/(  ( (D1^2)/(2*Tau) ) *( 1+2*(Se/Sn) ) + 2*M +1   );

wp1 = (  ( (1-D)^3/(2*Tau) ) * (1+2*Se/Sn) +1 +D  ) / ( R*C  );

Qp = 1/( pi * (mc*D1-0.5));

wn      = pi / Tsw; % oscillation at half of sw freq.


%% Low-Frequency Model

G_vc_l =  Ho* tf([(1/wz1) 1],[(1/(wp1)) 1]) *tf([(-1/wz2) 1],[1]) 


%% High-Frequency Correction Term

G_h = tf( 1,[(1/(wn^2)) (1/(wn*Qp)) 1])


%% Buck-  Boost Transfer Functions

G_vc =  G_vc_l * G_h   % 3rd order model (low freq pole + double poles at fs/2)

figure(1)
bodeplot(G_vc);
grid on;
hold on;

H = Vref / Vout;


RHPZ= wz2/(2*pi)
ESRzero= wz1/(2*pi)

RHPZ/5
ESRzero/5
fs/10

G_uc = G_vc * H ;  % uncompensated loop gain --> Gc = 1
%sisotool (G_uc);

%% Type II Compensator

A = 80000;
wzc = 5000;
wpc = 14e4;

R1 = 40e3 % assumption

C3 = wzc / (A * wpc * R1)
C1 = (1 / (R1 * A))
R2 = A * R1 / wzc
 
%% Closed loop TF
s = tf('s');
Gc = (A/s )*(1 + s/(wzc)) / (1 + s/(wpc));

Loop = G_uc * Gc;

figure(2)
bodeplot(Loop);
grid on;
hold on;

figure(3)
bodeplot(Gc);
grid on;
hold on;


%% Input to Output TF
Vac=Vdc;
Vap=Vdc+Vout;
Vcp=Vout;
Vc=1.5;
Ic=(Vc/Ri)-D*Tsw*Se-Vcp*(1-D)*Tsw/(2*L);
%Vc = Ri*(Ic+ (Tsw*Vcp*D1)/(2*L) + (D*Tsw*Se)/(Ri) )

D=Vcp/Vap;
D1=1-D;
ki=D/Ri;
go=(Tsw/L) *(D1*Se/Sn+0.5-D); 
gf=D*go-(D*D1)*Tsw/(2*L);

gi= D*(gf-Ic/Vap); 
gr=(Ic/Vap)-go*D;
ko=1/Ri;
C3=1/(L*(fs*pi)^2);


w0n=1/(sqrt((L*C3*gi)/(gi-gf)));
Qn= ( (gi-gf)*  sqrt((L*C3*gi)/(gi-gf))  ) / (L*(gf*gr-gi*go));
H0= ( R*(gf-gi))/(R*(gi-gf+go+gr)+1);


G_vg =  H0* tf([(1/wz1) 1],[(1/(wp1)) 1]) *tf([ (1/(w0n^2)) (1/(Qn*w0n)) 1],[1]) * tf(1 ,[(1/(wn^2)) (1/(wn*Qp)) 1])
 
figure(4)
bodeplot(-G_vg);
grid on;
hold on;

%sisotool (G_vg);


%% Output Impedance 
Ro = 1/(gr-gf+gi+gr+1/R); 

Zout = Ro *tf([1/wz1 1],[1/wp1 1])


figure(5)
bodeplot(Zout);
grid on;
hold on;

%sisotool (Zout);

