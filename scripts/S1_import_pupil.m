% Importing .edf files as separate .asc files for events and samples

clc
remAppledouble % Removes apple doubles. Havoc otherwise...
clear
close all
dbstop if error
dbstop if warning

%% Add paths and set folder structure

% Root directory for this project depending on OS
if ispc
    homedir = 'G:\Pilot_BB_behav';
elseif ismac
    homedir = '/Volumes/WORK/Pilot_BB_behav';
end

% Data folders
rawdir     = homedir;                            % Folder where the .edf files are stored
wrtdir     = [homedir, filesep, 'Converted'];    % Sub-folder where the .asc files are saved to

% EyeLink path depending on OS
if ispc
    edf2ascdir = 'C:\Program Files\EyeLink DataViewer 4.4';
    edf2asc = [edf2ascdir, filesep, 'edf2asc.exe'];
    edfapidll  = [edf2ascdir, filesep, 'edfapi.dll'];
elseif ismac
    edf2ascdir = '/Applications/EyeLink DataViewer 4.4';
    edf2asc = '/Applications/EyeLink DataViewer 4.4/EDFConverter.app/Contents/MacOS/EDFConverter';
    edfapidll  = '';  % Not needed on macOS
end

% Check if the necessary subfolders exist, and create them if they don't
if ~exist([wrtdir, filesep, 'events'], 'dir')
    mkdir([wrtdir, filesep, 'events']);
end
if ~exist([wrtdir, filesep, 'samples'], 'dir')
    mkdir([wrtdir, filesep, 'samples']);
end
if ~exist(rawdir, 'dir')
    mkdir(rawdir);
end

%% Get participant folders

participantFolders = dir(rawdir);
participantFolders = participantFolders([participantFolders.isdir] & ~ismember({participantFolders.name}, {'.', '..'})); %only subfolders, excluding '.' and '..'

%% Loop over participants
for p = 1:length(participantFolders)
    participantFolder = participantFolders(p).name; % participant subfolder name
    participantPath = fullfile(rawdir, participantFolder); % full path to participant folder

    % Get EDF files for the participant
    edfFiles = dir(fullfile(participantPath, '*.edf'));

    %% Loop over EDF files
    for fi = 1:length(edfFiles)
        edffile = edfFiles(fi).name;

        % Define full paths for the EDF file
        edffilePath = fullfile(participantPath, edffile);

        % Ensure full paths to the executable
        edf2asc = '/Applications/EyeLink DataViewer 4.4/EDFConverter.app/Contents/MacOS/EDFConverter';

        % Command for event conversion (separate output for events)
        command_event = ['"' edf2asc '" -input "' edffilePath '" -e "' fullfile(participantPath, [edffile(1:end-4), '_e.asc']) '"'];

        % Run the conversion for events
        disp(['Working on ' edffile ' events']);
        [status_event, cmdout_event] = system(command_event);
        disp('Event Conversion Output:');
        disp(cmdout_event);

        % Command for sample conversion (separate output for samples)
        command_sample = ['"' edf2asc '" -input "' edffilePath '" -s "' fullfile(participantPath, [edffile(1:end-4), '_s.asc']) '"'];

        % Run the conversion for samples
        disp(['Working on ' edffile ' samples']);
        [status_sample, cmdout_sample] = system(command_sample);
        disp('Sample Conversion Output:');
        disp(cmdout_sample);

        % Define paths for the converted event and sample files
        eventFile = fullfile(participantPath, [edffile(1:end-4), '_e.asc']);
        sampleFile = fullfile(participantPath, [edffile(1:end-4), '_s.asc']);

        % Move the event file to the appropriate folder (events)
        if exist(eventFile, 'file')
            % Define new location in the 'events' folder under 'Converted'
            movefile(eventFile, fullfile(wrtdir, 'events', [participantFolder, '_e.asc']));
            disp(['Moved event file to: ' fullfile(wrtdir, 'events', [participantFolder, '_e.asc'])]);
        else
            warning('Event file not created: %s', eventFile);
        end

        % Move the sample file to the appropriate folder (samples)
        if exist(sampleFile, 'file')
            % Define new location in the 'samples' folder under 'Converted'
            movefile(sampleFile, fullfile(wrtdir, 'samples', [participantFolder, '_s.asc']));
            disp(['Moved sample file to: ' fullfile(wrtdir, 'samples', [participantFolder, '_s.asc'])]);
        else
            warning('Sample file not created: %s', sampleFile);
        end
    end % end for fi
end % end for p