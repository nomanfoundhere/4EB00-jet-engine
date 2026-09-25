clear all;close all;clc;
%%
warning off
% addpath('D:\users\lsomers\Documents\Lectures\4EB00\2014\Matlab\General');
generalFolder=fullfile(fileparts(mfilename('fullpath')),'General'); % General folder next to this script, independent of MATLAB's current folder
addpath(generalFolder);
%% Some easy units
kJ=1e3;kmol=1e3;
%% Used by Nasa pols
global Runiv pref
Runiv=8.314472;
pref=1.01235e5; % Reference pressure, 1 atm!
Tref=298.15;    % Reference Temperature
%% Load Nasadatabase
TdataBase=fullfile(generalFolder,'NasaThermalDatabase');
load(TdataBase);
whos 
% Nasa is ready
%%
T=[300:10:4000]; % Define T vector
iSp1=myfind({Sp.Name},{'O2'});  % Find index for O2
iSp2=myfind({Sp.Name},{'O'});   % Find index for O

hO2=HNasa(T,Sp(iSp1));          % Compute specific enthalpy for O2 as function of T vector
MO2=Sp(iSp1).Mass;              % Molar mass (kg/mol)
hO=HNasa(T,Sp(iSp2));           % Compute specific enthalpy for O as function of T vector
MO=Sp(iSp2).Mass;               % Molar mass (kg/mol)
%% Your part
MyanswerExercise1

