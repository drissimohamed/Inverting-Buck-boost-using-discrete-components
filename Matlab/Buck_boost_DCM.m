%%  Converter Operating Point 
% 
clear; clc; close all;
Vdc = 24;
Vout = 12;
Iout = 0.12;
fs = 300e3; %switching freq
D=  Vout/(Vdc+Vout) %Duty cycle
D1=1-D;
R = Vout / Iout;  %Load
L = 22e-6; %induCtor 
C = 78.8e-6; %Output capacitor
Ri = 0.3;  %Shunt resistor 
rc = 0.002; %CAPACITOR ESR


Vref = 1.215;  %¨reference voltage
Tsw=1/fs ;

R4= 1.13e3;    %feedback resistors 
R5= 10e3;

%% Aux external ramp

sn = ((Vdc)/L)*Ri;
sf = ((Vout) / L)*Ri; 
se = 90000;  %external compensating ramp  

mc = 1 + (se/sn);

%% TF parameters

M = Vout/Vdc;

Tau = (L/R)*fs;

wz1 = 1/(rc*C);

wz2 = (R)/(M *(1+M)*L );

wp1 = 2/(R*C);

wp2 = 2*fs*( (1/D) / (1+(1/M)) )^2   ;

Ho=  Vdc/(sn*mc*Tsw*sqrt(2*Tau)) ;



%% Buck boost DCM Model

G_vc =  Ho* tf([(1/wz1) 1],[(1/(wp1)) 1]) *tf([(-1/wz2) 1],[(1/(wp2)) 1]) 




%% Buck-Boost Transfer Functions


figure(1)
bodeplot(G_vc);
grid on;
hold on;

H = Vref / Vout;


G_uc = G_vc * H ;  % uncompensated loop gain --> Gc = 1
sisotool (G_uc);

%% Type II Compensator

A = 80000;
wz1 = 5000;
wp1 = 14e4;

R1 = 40e3 % assumption

C3 = wz1 / (A * wp1 * R1)
C1 = (1 / (R1 * A))
R2 = A * R1 / wz1
 
