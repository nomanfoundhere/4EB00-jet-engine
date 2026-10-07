clear all;close all;clc;
warning off

%% To make sure that matlab will find the functions. You must change it to your situation 
generalFolder=fullfile(fileparts(mfilename('fullpath')),'General'); % General folder next to this script, independent of MATLAB's current folder
addpath(generalFolder);

%% Load Nasadatabase
TdataBase=fullfile(generalFolder,'NasaThermalDatabase');
load(TdataBase);

%% Nasa polynomials are loaded and globals are set. 
%% values should not be changed. These are used by all Nasa Functions. 
global Runiv Pref
Runiv=8.314472;
Pref=1.01235e5; % Reference pressure, 1 atm!
Tref=298.15;    % Reference Temperature

%% Some convenient units
kJ=1e3;kmol=1e3;dm=0.1;bara=1e5;kPa = 1000;kN=1000;kg=1;s=1;

%% Given conditions. 
%  For the final assignment take the ones from the specific case you are supposed to do.                  
v1=200;Tamb=300;P3overP2=9;Pamb=100*kPa;mfurate=0.58*kg/s;AF=170.35;        % Groep 42 (Groep042.txt)
cFuel='H2';                                                                 % Groep 42 fuel is H2 (other choices check Sp.Name)

%% Select species for the case at hand
iSp = myfind({Sp.Name},{cFuel,'O2','CO2','H2O','N2'});                      % Find indexes of these species
SpS=Sp(iSp);                                                                % Subselection of the database in the order according to {'H2','O2','CO2','H2O','N2'}
NSp = length(SpS);
Mi = [SpS.Mass];

%% Air composition
Xair = [0 0.21 0 0 0.79];                                                   % Order is important. Note that these are molefractions
MAir = Xair*Mi';                                                            % Row times Column = inner product 
Yair = Xair.*Mi/MAir;                                                       % Vector. times vector is Matlab's way of making an elementwise multiplication

%% Fuel composition
Yfuel = [1 0 0 0 0];                                                        % Only fuel

%% Range of enthalpies/thermal part of entropy of species
TR = [200:1:3000];NTR=length(TR);
for i=1:NSp                                                                 % Compute properties for all species for temperature range TR 
    hia(:,i) = HNasa(TR,SpS(i));                                            % hia is a NTR by 5 matrix
    sia(:,i) = SNasa(TR,SpS(i));                                            % sia is a NTR by 5 matrix
end

hair_a= Yair*hia';                                                          % Matlab 'inner product': 1x5 times 5xNTR matrix muliplication, 1xNTR resulT -> enthalpy of air for range of T 
sair_a= Yair*sia';                                                          % same but this thermal part of entropy of air for range of T
% whos hia sia hair_a sair_a                                                  % Shows dimensions of arrays on commandline

%% Two methods are presented to 'solve' the conservation equations for the Diffusor
%-------------------------------------------------------------------------
% ----> This part shows the interpolation method
% Bisection is in the next 'cell'
%-------------------------------------------------------------------------
% [1-2] Diffusor :: Example approach using INTERPOLATION
cMethod = 'Interpolation Method';
sPart = 'Diffusor';
T1 = Tamb;
P1 = Pamb;
Rg = Runiv/MAir;

for i=1:NSp
    hi(i)    = HNasa(T1,SpS(i));
end
h1 = Yair*hi';

v2 = 0;
h2 = h1+0.5*v1^2-0.5*v2^2;                                                  % Enhalpy at stage: h2 > h1 due to kinetic energy
T2 = interp1(hair_a,TR,h2);                                                 % Interpolate h2 on h2air_a to approximate T2. Pretty accurate

for i=1:NSp
    hi2(i)    = HNasa(T2,SpS(i));
    si1(i)    = SNasa(T1,SpS(i));
    si2(i)    = SNasa(T2,SpS(i));
end
h2check = Yair*hi2';                                                        % Single value (1x5 times 5x1). Why do I do compute this h2check value? Any ideas?

s1thermal = Yair*si1';
s2thermal = Yair*si2';
lnPr = (s2thermal-s1thermal)/Rg;                                            % ln(P2/P1) = (s2-s1)/Rg , see lecture (s2 are only the temperature integral part of th eentropy)
Pr = exp(lnPr);
P2 = P1*Pr;
S1  = s1thermal - Rg*log(P1/Pref);                                          % Total specific entropy
S2  = s2thermal - Rg*log(P2/Pref);

% Print to screen
fprintf('\n%14s\n',cMethod);
fprintf('Stage  ||%14s        [unit]\n      NR|%9i %9i\n',sPart,1,2);
fprintf('-------------------------------------\n');
fprintf('%8s| %9.2f %9.2f  [K]\n','Temp',T1,T2);
fprintf('%8s| %9.2f %9.2f  [kPa]\n','Press',P1/kPa,P2/kPa);
fprintf('%8s| %9.2f %9.2f  [m/s]\n','v',v1,v2);
fprintf('---  H/S    -------------------------\n');
fprintf('%8s| %9.2f %9.2f  [kJ/kg]\n','h',h1/kJ,h2/kJ);
fprintf('%8s| %9.2f %9.2f  [kJ/kg/K]\n','Total S',S1/kJ,S2/kJ);

T2int = T2;

%% Two methods are presented to 'solve' the conservation equations for the Diffusor
%-------------------------------------------------------------------------
% ----> This part shows the Bisection method
%-------------------------------------------------------------------------
% [1-2] Diffusor :: Example approach using bisection (https://en.wikipedia.org/wiki/Bisection_method)
cMethod = 'Bisection Method';
sPart = 'Diffusor';
T1 = Tamb;
P1 = Pamb;
Rg = Runiv/MAir;

for i=1:NSp
    hi(i)    = HNasa(T1,SpS(i));
end
h1 = Yair*hi';

v2 = 0;
h2 = h1+0.5*v1^2-0.5*v2^2;                                                  % Enhalpy at stage: h2 > h1 due to kinetic energy

TL = T1;
TH = 1000;                                                                  % A guess for the TH (must be too high)
iter = 0;
while abs(TH-TL) > 0.01
    iter = iter+1;
    Ti = (TL+TH)/2;
    for i=1:NSp
        hi2(i)    = HNasa(Ti,SpS(i));
    end
    h2i = Yair*hi2';                                                        % Single value (1x5 times 5x1). Intermediate value
    if h2i > h2
        TH = Ti; % new right boundary
    else
        TL = Ti; % new left boundary
    end
end

T2 = (TH+TL)/2;
T2bis = T2;

for i=1:NSp
    hi2(i)    = HNasa(T2,SpS(i));
    si1(i)    = SNasa(T1,SpS(i));
    si2(i)    = SNasa(T2,SpS(i));
end

s1thermal = Yair*si1';
s2thermal = Yair*si2';
lnPr = (s2thermal-s1thermal)/Rg;                                            % ln(P2/P1) = (s2-s1)/Rg , see lecture (s2 are only the temperature integral)
Pr = exp(lnPr);
P2 = P1*Pr;
S1  = s1thermal - Rg*log(P1/Pref);                                          % Total entropy stage 1
S2  = s2thermal - Rg*log(P2/Pref);                                          % Total entropy stage 2

% Print to screen
fprintf('\n%14s\n',cMethod);
fprintf('Stage  ||%14s        [unit]\n      NR|%9i %9i\n',sPart,1,2);
fprintf('-------------------------------------\n');
fprintf('%8s| %9.2f %9.2f  [K]\n','Temp',T1,T2);
fprintf('%8s| %9.2f %9.2f  [kPa]\n','Press',P1/kPa,P2/kPa);
fprintf('%8s| %9.2f %9.2f  [m/s]\n','v',v1,v2);
fprintf('---  H/S    -------------------------\n');
fprintf('%8s| %9.2f %9.2f  [kJ/kg]\n','h',h1/kJ,h2/kJ);
fprintf('%8s| %9.2f %9.2f  [kJ/kg/K]\n','Total S',S1/kJ,S2/kJ);

%% Difference between two approaches: so close but not identical
fprintf('----------------------------------------------\n%8s| %9.4f %9.4f  [K]\n----------------------------------------------\n','T2-int vs T2-bis',T2int,T2bis);

%% Here starts your part (compressor,combustor,turbine and nozzle). ...
% Make a choice for which type of solution method you want to use. We will
% use interpolation.

% Compressor
cMethod = 'Interpolation Method';
sPart = 'Compressor';

% Calculations
P3 = P3overP2 * P2;
S3 = S2;
s3thermal = S3 + Rg * log(P3/Pref);
T3 = interp1(sair_a, TR, s3thermal);

% Display
fprintf('P3 = %.6g kPa\n', P3/kPa);
fprintf('T3 = %.5g K\n', T3);

%% [3-4] Combustor: composition
% Species order: [H2 O2 CO2 H2O N2].

mair = AF*mfurate;                       % Air mass flow
mtot = mair+mfurate;                     % Total outlet mass flow

nreac = (mair*Yair+mfurate*Yfuel)./Mi;   % Inlet molar flow of each species
Yreac = nreac.*Mi/mtot;                  % Mass fractions before combustion

nprod = nreac+nreac(1)*[-1 -0.5 0 1 0];  % Outlet molar flows: H2 + 0.5 O2 -> H2O
Yprod = nprod.*Mi/mtot;                  % Mass fractions after combustion
mcheck = mtot-nprod*Mi';                 % Mass flow in minus out

RgReac = Runiv*sum(nreac)/mtot;          % Reactant gas constant
RgProd = Runiv*sum(nprod)/mtot;          % Product gas constant
AFst = 0.5*Mi(2)/(Mi(1)*Yair(2));        % Stoichiometric air/fuel mass ratio
phi = AFst/AF;                           % Equivalence ratio; below 1 means lean

%% [3-4] Combustor: thermodynamics
% Steady, adiabatic flow with no shaft work or potential energy change

cMethod = 'Interpolation Method';        % Method for the output
sPart = 'Combustor';                     % Component label for the output

P4 = P3;                                 % Constant-pressure outlet
Tfuel = Tamb;                            % Assumed fuel inlet temp
v3 = 0;                                  % Neglected inlet bulk velocity
v4 = 0;                                  % Neglected outlet bulk velocity

for i=1:NSp                              % Loop over the selected species.
    hi3(i) = HNasa(T3,SpS(i));           % Species enthalpy at air inlet temp
    hif(i) = HNasa(Tfuel,SpS(i));        % Species enthalpy at fuel inlet temp
end

h3 = Yair*hi3';                          % Incoming air enthalpy
hfuel = Yfuel*hif';                      % Incoming fuel enthalpy
h4 = (mair*h3+mfurate*hfuel)/mtot;       % Product enthalpy from energy balance

hprod_a = Yprod*hia';                    % Product enthalpy across TR
T4 = interp1(hprod_a,TR,h4);             % Outlet temp corresponding to h4

for i=1:NSp                              % Loop over the selected species.
    si4(i) = SNasa(T4,SpS(i));           % Species entropy at T4 and reference P
end

s4thermal = Yprod*si4';                  % Weighted reference-pressure entropy
S4 = s4thermal-RgProd*log(P4/Pref);      % Course entropy value, excluding mixing

%% Combustor results for the report
% Table 1 uses air at state 3 and products at state 4.
fprintf('\n%14s\n',cMethod);
fprintf('Stage  ||%14s        [unit]\n      NR|%9i %9i\n',sPart,3,4);
fprintf('-------------------------------------\n');
fprintf('%8s| %9.2f %9.2f  [K]\n','Temp',T3,T4);
fprintf('%8s| %9.2f %9.2f  [kPa]\n','Press',P3/kPa,P4/kPa);
fprintf('%8s| %9.2f %9.2f  [m/s]\n','v',v3,v4);
fprintf('%8s| %9.2f %9.2f  [kJ/kg]\n','h',h3/kJ,h4/kJ);
fprintf('%8s| %9.2f %9.2f  [kJ/(kg K)]\n','s*',S3/kJ,S4/kJ);
fprintf('s*: course entropy convention, excludes entropy of mixing.\n');
fprintf('Assumed fuel inlet temperature: %.2f K\n',Tfuel);

% Table 2 lists the combined reactants and products in the template's order.
cName = {'Fuel','O2','N2','CO2','H2O'};     % Row labels in Group42_report.docx.
iReport = [1 2 5 3 4];                    % Database indices for those report rows.
fprintf('\nTable 2: mixture composition\n');
fprintf('AF = %.2f kg/kg; equivalence ratio = %.4f\n',AF,phi);
fprintf('Stoichiometric AF = %.2f kg/kg\n',AFst);
fprintf('%8s| %9s %9s\n','Species','Initial','Final');
fprintf('-------------------------------------\n');
for j=1:NSp
    i = iReport(j);
    fprintf('%8s| %9.5f %9.5f\n',cName{j},Yreac(i),Yprod(i));
end
fprintf('%8s| %9.2f %9.2f  [J/(kg K)]\n','Rg',RgReac,RgProd);
fprintf('Mass fractions are in kg species/kg mixture.\n');
fprintf('Mass balance (in - out): %.2e kg/s\n',mcheck);

%% [4-5] Turbine
% Isentropic and adiabatic; all turbine work drives the compressor. Composition frozen at Yprod.
cMethod = 'Interpolation Method';
sPart = 'Turbine';

v5 = 0;                                                                     % Neglected outlet velocity [m/s]
Wcomp = mair*(h3-h2);                                                       % Compressor power, air only [W]
h5 = h4-Wcomp/mtot;                                                         % Work balance: mtot*(h4-h5) = mair*(h3-h2)
T5 = interp1(hprod_a,TR,h5);

for i=1:NSp
    si5(i) = SNasa(T5,SpS(i));
end
s5thermal = Yprod*si5';
P5 = P4*exp((s5thermal-s4thermal)/RgProd);                                  % s5 = s4: ln(P5/P4) = (s5th-s4th)/Rg
S5 = s5thermal-RgProd*log(P5/Pref);

Wturb = mtot*(h4-h5);

% Cross-check T5 with bisection
TL = TR(1);TH = T4;
while abs(TH-TL) > 0.01
    Ti = (TL+TH)/2;
    for i=1:NSp
        hi5(i) = HNasa(Ti,SpS(i));
    end
    if Yprod*hi5' > h5
        TH = Ti;
    else
        TL = Ti;
    end
end
T5bis = (TL+TH)/2;

fprintf('\n%14s\n',cMethod);
fprintf('Stage  ||%14s        [unit]\n      NR|%9i %9i\n',sPart,4,5);
fprintf('-------------------------------------\n');
fprintf('%8s| %9.2f %9.2f  [K]\n','Temp',T4,T5);
fprintf('%8s| %9.2f %9.2f  [kPa]\n','Press',P4/kPa,P5/kPa);
fprintf('%8s| %9.2f %9.2f  [m/s]\n','v',v4,v5);
fprintf('%8s| %9.2f %9.2f  [kJ/kg]\n','h',h4/kJ,h5/kJ);
fprintf('%8s| %9.4f %9.4f  [kJ/(kg K)]\n','s*',S4/kJ,S5/kJ);
fprintf('Compressor power %.3f MW, turbine power %.3f MW\n',Wcomp/1e6,Wturb/1e6);
fprintf('T5 interpolation vs bisection: %.4f vs %.4f K\n',T5,T5bis);
