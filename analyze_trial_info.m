function trial_info = analyze_trial_info(selpath)

    if nargin == 0
        
        startPath = 'W:\Data\2AFC_Behavior';
        selpath = uigetdir(startPath);
    end
    
    
    %Make a new filename using the name of the directory you select
    f = split(selpath, ["\"]);
    filepath = [selpath,'\','ttl_info_',f{end},'.mat'];
    
    %Checks to see if file was already generated, if so, it loads the
    %data as well as identifying which sessions have already been
    %analyzed. If not, it initalizes the variables to be saved. 
    if isfile(filepath)
        load(filepath, 'trial_info');
        loadedSessions = unique(trial_info.sessions);
        disp(strcat("Loading data from ", filepath));
    else
        loadedSessions = 'nan';
              
        trial_info.lick = [];
        trial_info.h2o = [];
        trial_info.sessions = [];
        trial_info.good_trials = [];
         
        disp(strcat("No file exists, creating file ",filepath));
    end
    
    % Pulls out all the names of the folders in the directory you chose to
    % determine how many possible sessions exist and making a list of those
    % filenames
    sessionFolders = dir(selpath);
    filenames = extractfield(sessionFolders, 'name');
    filenames = filenames(contains(filenames, 'Session'));
  
    
    % dir puts the filenames in alphabetical order, so you need to re-sort
    % them based on the session number to ensure you're keeping things
    % chronological
    sessionNum = cellfun(@str2num, (regexp(cell2mat(filenames), '\d*', 'Match')));
    [~,sortIdx] = sort(sessionNum,'ascend');
    filenames = filenames(sortIdx);
    
    %Determines which of those folders to analyze by comparing the list
    %from the folder to the list from the data file
    if ~isempty(trial_info.sessions)
        extractSessions = filenames( ~ismember(sessionNum, loadedSessions));
    else
        extractSessions = filenames;
    end
    
    
 
    for currentDay = 1:length(extractSessions)
       
        inputPath = [selpath, '\', extractSessions{currentDay}];
        t = analyze_session_trial_info(inputPath);
        
        trial_info.sessions = [trial_info.sessions, t.sessions];
        l = cat(3, t.lick1, t.lick2);
        trial_info.lick = cat(1, trial_info.lick, l);
        h = cat(3, t.h2o1, t.h2o2);
        trial_info.h2o = cat(1, trial_info.h2o, h);
        trial_info.good_trials = [trial_info.good_trials, t.good_trials];
    end
   
    if ~isempty(extractSessions)
        save(filepath, 'trial_info');
    end
end