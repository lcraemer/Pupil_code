%% clear contents
clc
clear all
close all

%% add paths and set folder structure

% root directory for this project
if ispc
    homedir = 'G:\Pilot_BB_behav';  % For Windows
elseif ismac
    homedir = '/Volumes/WORK/Pilot_BB_behav/';  % For macOS
else
    error('Unsupported operating system');
end

% data folders
rawdir = fullfile(homedir, 'eyetracker', 'rawedf'); % folder where the .edf files are stored
wrtdir = fullfile(homedir, 'eyetracker', 'asci'); % sub-folder where the .asc files are saved to
edf2ascdir = fullfile(userpath, 'Pupil_code', 'functions', 'edf2asc'); % folder that contains the conversion program

% files that do the conversion from .edf to .asc process
edf2ascexe = fullfile(edf2ascdir, 'edf2asc.exe');
edfapidll  = fullfile(edf2ascdir, 'edfapi.dll');

% if the folders where the data are written out to don't yet exist, create them
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
    if exist(fullfile(wrtdir, 'events', [edffile(1:end-4) '_e.asc']), 'file')
        disp(['Skipping ' edffile ' events']);
        continue;
    end
    if exist(fullfile(wrtdir, 'samples', [edffile(1:end-4) '_s.asc']), 'file')
        disp(['Skipping ' edffile ' samples']);
        continue;
    end

    % Construct full file paths for the input .edf file
    edf_file_path = fullfile(rawdir, edffile);
    
    % Ensure output file paths include the .asc extension
    events_output_file = fullfile(rawdir, [edffile(1:end-4) '_e.asc']);
    samples_output_file = fullfile(rawdir, [edffile(1:end-4) '_s.asc']);
    
    %% Convert EDF to ASCII file (events)
    command_events = ['"' edf2ascexe '" -ns "' edf_file_path '" "' events_output_file '"'];
    disp(['Running command: ' command_events]); % Display the command to verify its correctness
    
    % Execute the system command for events
    system(command_events);
    
    %% Convert EDF to ASCII file (samples)
    command_samples = ['"' edf2ascexe '" -ne "' edf_file_path '" "' samples_output_file '"'];
    disp(['Running command: ' command_samples]); % Display the command to verify its correctness
    
    % Execute the system command for samples
    system(command_samples);
    
    %% Move converted files to appropriate folders
    movefile(events_output_file, fullfile(wrtdir, 'events'));
    movefile(samples_output_file, fullfile(wrtdir, 'samples'));

    % Optional: Clean up (if you need to delete temporary files)
    % delete('edf2asc.exe', 'edfapi.dll');
end
