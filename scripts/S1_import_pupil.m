%% clear contents
clc
remAppledouble
clear all
close all

%% Setup directory paths
homedir = 'G:\Pilot_BB_behav';
rawdir = fullfile(homedir, 'eyetracker', 'rawedf');
ascdir = fullfile(homedir, 'eyetracker', 'ascii');
if ~exist(ascdir, 'dir')
    mkdir(ascdir);
end
if ~exist(fullfile(ascdir, 'events'), 'dir')
    mkdir(fullfile(ascdir, 'events'));
end
if ~exist(fullfile(ascdir, 'samples'), 'dir')
    mkdir(fullfile(ascdir, 'samples'));
end
if ~exist(rawdir, 'dir')
    mkdir(rawdir);
end

% Set paths for EDF to ASCII conversion
edf2ascdir = fullfile('C:\Program Files\SR Research\edfconverter');
edf2ascexe = fullfile(edf2ascdir, 'edfconverterW.exe');
edfapidll  = fullfile(edf2ascdir, 'edfapi64.dll');

% Loop through all .edf files in the rawdir
files = dir(fullfile(rawdir, '*.edf'));
for i = 1:length(files)
    edffile = files(i).name;

    % Get the base file name without the extension
    [~, baseName, ~] = fileparts(edffile);

    % Construct full file paths for the input .edf file
    edf_file_path = fullfile(rawdir, edffile);

    %% Convert EDF to ASCII (events)
    command_events = ['"' edf2ascexe '" -ne "' edf_file_path '"'];
    disp(['Running command for events: ' command_events]);
    status = system(command_events);

    if status == 0
        disp(['Successfully converted events for: ', edffile]);

        % Identify the created events file (it should be created in the same directory)
        events_file = fullfile(rawdir, [baseName '.asc']);

        % Check if the file exists and move it
        if exist(events_file, 'file')
            movefile(events_file, fullfile(ascdir, 'events', [baseName '_e.asc']));
        else
            disp(['Error: Events file not created for: ', edffile]);
        end
    else
        disp(['Error converting events for: ', edffile]);
        continue;
    end

    %% Convert EDF to ASCII (samples)
    command_samples = ['"' edf2ascexe '" -ns "' edf_file_path '"'];
    disp(['Running command for samples: ' command_samples]);
    status = system(command_samples);

    if status == 0
        disp(['Successfully converted samples for: ', edffile]);

        % Identify the created samples file (it should be created in the same directory)
        samples_file = fullfile(rawdir, [baseName '.asc']);

        % Check if the file exists and move it
        if exist(samples_file, 'file')
            movefile(samples_file, fullfile(ascdir, 'samples', [baseName '_s.asc']));
        else
            disp(['Error: Samples file not created for: ', edffile]);
        end
    else
        disp(['Error converting samples for: ', edffile]);
        continue;
    end
end