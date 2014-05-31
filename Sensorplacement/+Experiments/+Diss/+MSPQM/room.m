close all; 
clear all;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
config = Configurations.Discretization.iterative;

environment = Environment.load(filename);

