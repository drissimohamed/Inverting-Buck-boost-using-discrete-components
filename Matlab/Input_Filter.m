%% ═══════════════════════════════════════════════════════════
%  Input Filter  Analysis
%  Inverting Buck-Boost PCMC
%  Engineer: Mohamed Drissi
%% ═══════════════════════════════════════════════════════════
%%  Converter Operating Point

clear; clc; close all;
Vdc = 24;
Vout = 12;
Iout = 3;
Pout= Vout *Iout;
Iin = Vdc/Pout;
fs = 300e3; %switching freq
D=  Vout/(Vdc+Vout) %Duty cycle
D1=1-D;
R = Vout / Iout;  %Load
L = 22e-6; %induCtor 
C = 78.8e-6; %Output capacitor
Ri = 0.3;  %Shunt resistor 
rc = 0.002; %CAPACITOR ESR
rl=50e-3 ; %Inductor DCR 

Vref = 1.215;  %¨reference voltage
Tsw=1/fs ;



%% ── Input Filter Parameters ──────────────────────────────────
Lf      = 47e-6;       % Filter inductor [H]
Cf      = 2.2e-6;      % X capacitor [F]
Rdamp   =4.7;         % Damping resistor [Ohm]
Cdamp   = 22e-6;      % Damping capacitor [F]
Rsrc    = 0.1;         % Source resistance [Ohm]
Lsrc    = 200e-9;      % Source inductance [H]

s    = tf('s');
%% ── Input Filter Output Impedance ────────────────────────────
% LC filter with damping network (Rdamp + Cdamp in parallel with Cf)
% Plus source impedance

% Damping branch: Rdamp in series with Cdamp
Z_damp = Rdamp + 1/(s*Cdamp);

% Cf in parallel with damping branch
Z_Cf_parallel = (1/(s*Cf) * Z_damp) / (1/(s*Cf) + Z_damp);

% Filter inductor Lf in series
Z_Lf = s*Lf;

% Source impedance
Z_src = Rsrc + s*Lsrc;

% Total filter output impedance seen by converter
% (Thevenin impedance looking back into filter)
Z_filter = (Z_Lf * Z_Cf_parallel) / (Z_Lf + Z_Cf_parallel);

% Add source impedance
Z_filter_total = Z_filter + Z_src;

%% Input impedance of IBB 
Sn = ((Vdc)/L)*Ri;
Sf = ((Vout) / L)*Ri; 
Se=90000;
mc = 1 + (Se/Sn);

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
req= 1/(1/(1/go)+(1/R)+(1/rc));
Ro= ((gi-gf+go+gr)*R+1) / ( (gf*gr+gi*go)*R+gi ); 

Tau = (L/R)*fs;

%coeff 

tau1 =L/( ( (R*(gf*gr+gi*go) + gi)/(gf*gr+gi*go) ) +rl );
tau2 =  ( ((R*gi)/ (R*(gf*gr+gi*go)+gi )  ) +rc )* C;
tau3 =  (  (R*gi)/(R*(gf*gr+gi*go)+gi ) ) *C3;

b1 = tau1 + tau2 +tau3;


tau12 = (rc+R)*C;
tau13 = 1/( (1/(gi/(gf*gr))) + (1/(1/go)) )*C3;
tau23 = ((req*gi)/( gi*(2*req*gf+1)+req*gf*gr )) * C3;

b2 = tau1 *tau12 + tau1 * tau13 +tau2 *tau23 ; 

b3 = tau1 *tau12*tau13; 


%HF TF 
wz1 = (  ( (1-D)^3/(2*Tau) ) * (1+2*Se/Sn) +1 +D  ) / ( R*C  );

Qp = 1/( pi * (mc*D1-0.5));

wn= pi / Tsw; % oscillation at half of sw freq.



%% Impedance TF
Zin=  Ro* tf([(1/wz1) 1],[b3 b2 b1 1]) * tf( [(1/(wn^2)) (1/(wn*Qp)) 1],1)


%% ── Colors ───────────────────────────────────────────────────
color_Zin     = [0.00 0.45 0.74];   % Blue
color_Zfilter = [0.85 0.33 0.10];   % Orange

%% ── Bode Options ─────────────────────────────────────────────
opt = bodeoptions('cstprefs');
opt.FreqUnits          = 'Hz';
opt.MagUnits           = 'dB';
opt.PhaseUnits         = 'deg';
opt.Grid               = 'on';
opt.XLabel.FontSize    = 13;
opt.YLabel.FontSize    = 13;
opt.TickLabel.FontSize = 12;


%% ── Figure ───────────────────────────────────────────────────
figure('Name',     'Middlebrook Criterion', ...
       'Position', [50 50 1300 780], ...
       'Color',    'white');

h1 = bodeplot(Zin,            opt); hold on;
h2 = bodeplot(Z_filter_total, opt);

%% ── Get Axes ─────────────────────────────────────────────────
allAxes = findall(gcf, 'Type', 'Axes');
magAx   = allAxes(1);
phAx    = allAxes(2);


%% ── Line Styling ─────────────────────────────────────────────
set(findall(gcf,'Type','line'),'LineWidth',2.5)

allLines = findall(gcf,'Type','line');

set(allLines(1:2:end), 'LineStyle','-')
set(allLines(2:2:end), 'LineStyle','-')

%% ── Axes Styling ─────────────────────────────────────────────
set(magAx, 'FontSize', 12, 'FontWeight', 'bold', ...
           'GridAlpha', 0.3, 'MinorGridAlpha', 0.15, ...
           'GridLineStyle', '--', ...
           'XMinorGrid', 'on', 'YMinorGrid', 'on', 'Box', 'on');
set(phAx,  'FontSize', 12, 'FontWeight', 'bold', ...
           'GridAlpha', 0.3, 'MinorGridAlpha', 0.15, ...
           'GridLineStyle', '--', ...
           'XMinorGrid', 'on', 'YMinorGrid', 'on', 'Box', 'on');

%% ── Titles and Labels ────────────────────────────────────────
title(magAx, ...
    {'Middlebrook Criterion — Input Filter Stability Verification', ...
     'Inverting Buck-Boost PCMC | Z_{in,converter} vs Z_{filter,out}'}, ...
    'FontSize', 13, 'FontWeight', 'bold');

ylabel(magAx, 'Impedance Magnitude [dB\Omega]', ...
       'FontSize', 13, 'FontWeight', 'bold');
ylabel(phAx,  'Phase [deg]', ...
       'FontSize', 13, 'FontWeight', 'bold');
xlabel(phAx,  'Frequency [Hz]', ...
       'FontSize', 13, 'FontWeight', 'bold');

%% ── Key Frequencies ──────────────────────────────────────────
fc_filter = 1/(2*pi*sqrt(Lf*Cf));
fc_loop   = 7060;
fRHP      = ((D1^2)*R)/(D*L)/(2*pi);

%% ── Frequency Markers ────────────────────────────────────────
xline(magAx, fc_loop, '-.','HandleVisibility', ...
    'Color', [0.2 0.6 0.2], 'LineWidth', 2, ...
    'Label', sprintf('f_c = %.1f kHz', fc_loop/1e3), ...
    'FontSize', 10, 'FontWeight', 'bold', ...
    'LabelVerticalAlignment',   'top', ...
    'LabelHorizontalAlignment', 'right');

xline(magAx, fc_filter, ':','HandleVisibility', ...
    'Color', [0.8 0.4 0.0], 'LineWidth', 2, ...
    'Label', sprintf('f_{c,filter} = %.1f kHz', fc_filter/1e3), ...
    'FontSize', 10, 'FontWeight', 'bold', ...
    'LabelVerticalAlignment',   'bottom', ...
    'LabelHorizontalAlignment', 'left');

xline(magAx, fs, '--','HandleVisibility', ...
    'Color', [0.5 0.5 0.5], 'LineWidth', 1.8, ...
    'Label', sprintf('f_s = %d kHz', fs/1e3), ...
    'FontSize', 10, ...
    'LabelVerticalAlignment',   'top', ...
    'LabelHorizontalAlignment', 'left');

xline(magAx, fRHP/5, ':','HandleVisibility', ...
    'Color', [0.7 0.0 0.7], 'LineWidth', 1.8, ...
    'Label', sprintf('f_{RHP}/5 = %.1f kHz', fRHP/5/1e3), ...
    'FontSize', 10, ...
    'LabelVerticalAlignment',   'bottom', ...
    'LabelHorizontalAlignment', 'right');

xline(phAx, fc_loop,   '-.', 'Color', [0.2 0.6 0.2], 'LineWidth', 1.5);
xline(phAx, fc_filter, ':',  'Color', [0.8 0.4 0.0],  'LineWidth', 1.5);
xline(phAx, fs,        '--', 'Color', [0.5 0.5 0.5],  'LineWidth', 1.5);


%% ── Shaded Regions ───────────────────────────────────────────
yl = ylim(magAx);

% Critical zone: DC to fc
patch(magAx, [1 fc_loop fc_loop 1], [yl(1) yl(1) yl(2) yl(2)], ...
    [0.0 0.8 0.0], 'FaceAlpha', 0.04, 'EdgeColor', 'none', ...
    'HandleVisibility', 'off');

% Important zone: fc to fs
patch(magAx, [fc_loop fs fs fc_loop], [yl(1) yl(1) yl(2) yl(2)], ...
    [1.0 0.9 0.0], 'FaceAlpha', 0.04, 'EdgeColor', 'none', ...
    'HandleVisibility', 'off');

% Irrelevant zone: above fs
patch(magAx, [fs 1e6 1e6 fs], [yl(1) yl(1) yl(2) yl(2)], ...
    [0.5 0.5 0.5], 'FaceAlpha', 0.06, 'EdgeColor', 'none', ...
    'HandleVisibility', 'off');

%% ── Zone Labels ──────────────────────────────────────────────
text(magAx, sqrt(1*fc_loop), yl(2)*0.88, ...
    {'CRITICAL', 'Z_{filt} < Z_{in}'}, ...
    'FontSize', 10, 'FontWeight', 'bold', ...
    'Color', [0.0 0.45 0.0], 'HorizontalAlignment', 'center');

text(magAx, sqrt(fc_loop*fs), yl(2)*0.88, ...
    {'IMPORTANT'}, ...
    'FontSize', 10, 'FontWeight', 'bold', ...
    'Color', [0.6 0.5 0.0], 'HorizontalAlignment', 'center');

text(magAx, sqrt(fs*1e6), yl(2)*0.88, ...
    {'IRRELEVANT', '> f_s'}, ...
    'FontSize', 10, 'FontWeight', 'bold', ...
    'Color', [0.4 0.4 0.4], 'HorizontalAlignment', 'center');

%% ── Legend ───────────────────────────────────────────────────
lgd = legend('Z{in} converter', 'Z{out} filter','Location', 'southwest');

lgd.FontSize = 13;
lgd.Box = 'on';
lgd.ItemTokenSize = [40 18];

%% ── Annotation ───────────────────────────────────────────────
annotation('textbox', [0.13 0.13 0.28 0.14], ...
    'String', {
        '── Operating point ────────────────', ...
        sprintf('  V_{in} = %d V  |  V_{out} = %d V', Vdc, Vout), ...
        sprintf('  D = %.3f  |  f_s = %d kHz', D, fs/1e3), ...
        sprintf('  L_f = %.0f uH  |  C_f = %.1f uF', Lf*1e6, Cf*1e6), ...
        sprintf('  R_{damp} = %.1f Ohm  |  C_{damp} = %.1f uF', ...
                Rdamp, Cdamp*1e6), ...
        sprintf('  f_{c,filter} = %.2f kHz', fc_filter/1e3)}, ...
    'FontSize',        10,  ...
    'FontName',        'Courier New', ...
    'BackgroundColor', [0.97 0.97 0.97], ...
    'EdgeColor',       [0.2  0.2  0.2], ...
    'LineWidth',        1.5, ...
    'FitBoxToText',    'on');