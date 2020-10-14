% Script to run the simple climate model
% through the various historical and
% future scenarios.
close all; clear all; clc;

% Make a constants/parameters structure that
% is read into the model.
params;

% Run the forcing scripts that read and structure
% historical and future forcing scenarios.
herf; 
giss;
pathways;
emit;


% Finally run the scenarios through the model with the
% prescribed forcing scenarios.
scenarios;
cd ../usr

