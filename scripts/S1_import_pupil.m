%% clear contents
clc
remAppledouble
clear all
close all

%% Setup directory paths
if ispc
    homedir = 'G:\Pilot_BB_behav';
elseif ismac
    homedir = '/Volumes/WORK/Pilot_BB_behav'
end
rawdir = fullfile(homedir, 'eyetracker', 'rawedf');
ascdir = fullfile(homedir, 'eyetracker', 'ascii');

% Set paths for EDF to ASCII conversion
edf2ascdir = fullfile(userpath, 'Pupil_code_orig', 'functions', 'edf2asc');
edf2ascexe = fullfile(edf2ascdir, 'edf2asc.exe');
edfapidll  = fullfile(edf2ascdir, 'edfapi.dll');

%% Get files to process

filz = dir(fullfile(rawdir, '*.edf'));

%% Loop over files

for i = 1:length(filz)

    %% Define output files, and check if they are already there

    edffile = filz(i).name;
    if exist(fullfile(ascdir, 'events', [edffile(1:end-4) '_e.asc']), 'file');
        disp(['skipping ' edffile]);
        continue;
    end

    %% Place the conversion program in the pupil data folder

    % Check if the conversion program files already exist in the pupil data folder
    if ~exist(fullfile(rawdir, 'edf2asc.exe'), 'file') || ~exist(fullfile(rawdir, 'edfapi.dll'), 'file')
        % Place the conversion program in the pupil data folder
        copyfile(edf2ascexe, rawdir);
        copyfile(edfapidll, rawdir);
    end

    %% Convert EDF to ASCII and move file

    cd(rawdir)

   % Run the conversion to .asc (events)
disp(['working on ' edffile ' events']);
[status, cmdout] = system(['edf2asc -ns "' fullfile(rawdir, edffile) '" "' fullfile(rawdir, [edffile(1:end-4) '_e']) '"']);
if status ~= 0
    disp(['Error with conversion (events): ' cmdout]);
else
    disp(['Successfully converted events: ' edffile]);
end

% Run the conversion to .asc (samples)
disp(['working on ' edffile ' samples']);
[status, cmdout] = system(['edf2asc -ne "' fullfile(rawdir, edffile) '" "' fullfile(rawdir, [edffile(1:end-4) '_s']) '"']);
if status ~= 0
    disp(['Error with conversion (samples): ' cmdout]);
else
    disp(['Successfully converted samples: ' edffile]);
end



    movefile(fullfile(rawdir, [edffile(1:end-4) '_e.asc']), fullfile(ascdir, 'events'));
    movefile(fullfile(rawdir, [edffile(1:end-4) '_s.asc']), fullfile(ascdir, 'samples'));

    % Converter clean up
    delete(fullfile(rawdir, 'edf2asc.exe'), fullfile(rawdir, 'edfapi.dll'));

end
