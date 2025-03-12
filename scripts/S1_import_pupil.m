%% clear contents
clc
remAppledouble
clear all
close all

%% Setup directory paths
if ispc
    homedir = 'G:\Pilot_BB_behav';  % For Windows
elseif ismac
    homedir = '/Volumes/WORK/Pilot_BB_behav/';  % For macOS
else
    error('Unsupported operating system');
end

% Data folders
rawdir = fullfile(homedir, 'eyetracker', 'rawedf'); % Folder where the .edf files are stored
wrtdir = fullfile(homedir, 'eyetracker', 'ascii'); % Sub-folder where the .asc files are saved
edf2ascdir = fullfile('C:\Program Files\SR Research\edfconverter'); % Folder that contains the conversion program

% Files that do the conversion from .edf to .asc process
edf2ascexe = fullfile(edf2ascdir, 'edfconverterW.exe');
edfapidll  = fullfile(edf2ascdir, 'edfapi64.dll');

% Create output folders if they do not exist
if ~exist(wrtdir, 'dir')
    mkdir(fullfile(wrtdir, 'events'));
    mkdir(fullfile(wrtdir, 'samples'));
end
if ~exist(rawdir, 'dir')
    mkdir(rawdir);
end

%% Loop through all .edf files in the rawdir
files = dir(fullfile(rawdir, '*.edf'));  % List all .edf files
for i = 1:length(files)
    edffile = files(i).name;  % Get the current .edf file name

    % Skip if the corresponding .asc files already exist
    events_output_file = fullfile(wrtdir, 'events', [edffile(1:end-4) '_e.asc']);
    samples_output_file = fullfile(wrtdir, 'samples', [edffile(1:end-4) '_s.asc']);
    
    if exist(events_output_file, 'file')
        disp(['Skipping ' edffile ' events']);
        continue;
    end
    if exist(samples_output_file, 'file')
        disp(['Skipping ' edffile ' samples']);
        continue;
    end

    % Construct full file paths for the input .edf file
    edf_file_path = fullfile(rawdir, edffile);

    %% Convert EDF to ASCII (events)
    command_events = ['"' edf2ascexe '" -ns "' edf_file_path '" "' events_output_file '"'];
    remAppledouble
    disp(['Running command for events: ' command_events]);
    status = system(command_events);  % Execute the conversion for events

    if status == 0  % Check if the conversion was successful
        disp(['Successfully converted events for: ', edffile]);
    else
        disp(['Error converting events for: ', edffile]);
        continue;
    end

    %% Convert EDF to ASCII (samples)
    command_samples = ['"' edf2ascexe '" -ne "' edf_file_path '" "' samples_output_file '"'];
    remAppledouble
    disp(['Running command for samples: ' command_samples]);
    status = system(command_samples);  % Execute the conversion for samples

    if status == 0  % Check if the conversion was successful
        disp(['Successfully converted samples for: ', edffile]);
    else
        disp(['Error converting samples for: ', edffile]);
        continue;
    end

end