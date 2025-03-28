% Script for extracting pupil and event data from -ascii eye-tracker files
% and creating .mat files

% This script requires two things:
%     (1) -ascii files containing event information
%     (2) -ascii files containing the event information

clc
remAppledouble
clear all
close all


warning('off','all')

%% add paths and set folder structure

%root directory for this project
if ispc
    homedir = 'G:\Pilot_BB_behav';
elseif ismac
    homedir = '/Volumes/WORK/Pilot_BB_behav'
end

%data folders
rawdir = fullfile(homedir, 'eyetracker', 'rawedf');
ascdir = fullfile(homedir, 'eyetracker', 'ascii');
pupildir = fullfile(ascdir, 'samples');
eventsdir = fullfile(ascdir, 'events');

%start up EEGLAB
eeglab, close

if ~exist(ascdir,'dir');
    mkdir(ascdir); end

%% get files

% get list of files to process
filz = dir(fullfile(eventsdir, '*.asc'));

%sample rate of the pupil data
srate = 1000;

%% extracting event information

for i = 1:length(filz) % looping through all files to process

    %% file checking
    filename    = filz(i).name; %file to read
    outfilename = [filename(1:end-6) '.mat']; %file to write

    %skip files if they're done already
    if exist([ascdir outfilename],'file'); disp(['skipping file: ' filename]); continue; end
    disp(['workig on file: ' filename])

    %% now get event information

    %code in this cell will generate the variable 'events' that contains
    %information about stimulus presentation and response information etc.
    %It is of size n x 2, with n being the number of trials. The two
    %columns indicate 1) timing of the event (in seconds) and 2) type of
    %event (e.g. which button was pressed)

    cd(eventsdir);   % changing directory
    events_name = filename;

    cd(pupildir); % changing to pupil data directory
    pupil_name = [filename(1:end-5) 's.asc']; % file with data (sample) information

    fid = fopen(pupil_name, 'r');
    if fid == -1
        error(['Could not open file: ' pupil_name]);
    end

    % Use a format that only captures the first five numeric fields
    pupil_text = textscan(fid, '%f%f%f%f%f', 'Headerlines', 0, 'ReturnOnError', 0);
    fclose(fid);

    % Display the parsed data
    disp('Parsed Data:');
    disp(pupil_text);

    %%% Hab ich nicht...?
    convert2diam = false;

    % Convert numeric columns manually if they contain valid numbers
    for col = [1, 4] % Columns that are expected to be numeric
        for row = 1:length(pupil_text{col})
            % Check if the current entry is numeric or a valid number
            num_value = pupil_text{col}(row); % Direct indexing if it's a numeric vector
            if ~isnan(num_value)
                pupil_text{col}{row} = num_value;
            else
                pupil_text{col}{row} = NaN; % Replace problematic values with NaN
            end
        end
    end


    if isnan(convert2diam)
        error('No valid recording setup detected')
    end



    trl = 0;
    events = [];
    for i = 1:length(filz)
        trlmarker = cell2mat(event_text{1,3}(i));
        if isempty(str2num(trlmarker)); continue, end %skip calibration, validation, etc markers
        if strcmp(cell2mat(event_text{1,1}(i)),'MSG') == 1 %if this is a trigger message
            events(size(events,1)+1,1) = (str2num(cell2mat(event_text{1,2}(i)))-start_time)/1000; %event latency
            events(size(events,1),2) = str2num(trlmarker); %event type
            trl = trl +1;
        end
    end


    %% extracting pupil data

    %the code in this cell will generate the variable 'final_pupil', which
    %is a 3 x n matrix where n is samples. The three colums are 1) pupil
    %diameter, 2) gaze x position, and 3) gaze y position.

    cd(pupildir); % changing to pupil data directory
    pupil_name = [filename(1:end-5) 's.asc']; % file with data (sample) information

    fid = fopen(pupil_name);
    try
        pupil_text = textscan(fid,'%n%s%s%n%s','Headerlines',0,'ReturnOnError',0);
    catch ME
        pupil_text = textscan(fid,'%n%s%s%n%s%s%s%s%s','Headerlines',0,'ReturnOnError',0);
    end
    fclose(fid);

    % isolating pupil data which is before 'start_time'
    prestart_pupil = zeros(size(pupil_text{1,1},1),1);
    full_gaze_x = zeros(size(pupil_text{1,1},1),1);
    full_gaze_y = zeros(size(pupil_text{1,1},1),1);
    for i = 1:length(prestart_pupil)
        if (pupil_text{1,1}(i)) < start_time %see previous cell for finding the start time of the recording
            prestart_pupil(i) = 1;
        end
        if ~strcmp(pupil_text{1,2}(i),'.')
            full_gaze_x(i) = str2num(pupil_text{1,2}{i});
        end
        if ~strcmp(pupil_text{1,3}(i),'.')
            full_gaze_y(i) = str2num(pupil_text{1,3}{i});
        end
    end

    cutoff_sample = sum(prestart_pupil);

    final_pupil      = ((pupil_text{1,4}(cutoff_sample+1:length(prestart_pupil))))';
    final_pupil(2,:) = full_gaze_x(cutoff_sample+1:length(prestart_pupil))';
    final_pupil(3,:) = full_gaze_y(cutoff_sample+1:length(prestart_pupil))';

    %% if we accidentally recorded area instead of diameter, perform a conversion

    if convert2diam
        final_pupil(1,:) = 256.*sqrt(final_pupil(1,:) ./ pi);
    end

    %% creating EEGLAB dataset and saving to file

    clear EEG ALLEEG

    % importing data from variables created earlier
    EEG = pop_importdata( 'dataformat', 'array', 'data', 'final_pupil', 'setname', outfilename, 'srate', srate, 'pnts',0, 'xmin',0, 'nbchan',3);
    EEG = eeg_checkset( EEG );
    EEG = pop_importevent( EEG, 'event',events,'fields',{'latency' 'type' },'timeunit',1);
    EEG = eeg_checkset( EEG );

    ALLEEG = EEG;

    save([ascdir outfilename],'EEG');


end