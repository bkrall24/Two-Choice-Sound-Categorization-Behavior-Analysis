function pupil = analyze_pupil(selpath)

    if nargin == 0
        startPath = 'W:\Data\2AFC_Behavior';
        selpath = uigetdir(startPath);
    end
    
    
    
    %Make a new filename using the name of the directory you select
    f = split(selpath, ["\"]);
    filepath = [selpath,'\','pupil_',f{end},'.mat'];
    
    %Checks to see if file was already generated, if so, it loads the
    %data as well as identifying which sessions have already been
    %analyzed. If not, it initalizes the variables to be saved. 
    if isfile(filepath)
        load(filepath, 'pupil');
        loadedSessions = unique(pupil.sessionNum);
        disp(strcat("Loading data from ", filepath));
    else
        loadedSessions = 'nan';
        pupil.diameter = [];
        pupil.sessionNum = [];         
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
    extractSessions = filenames( ~ismember(sessionNum, loadedSessions));
    
    
 
    for currentDay = 1:length(extractSessions)
       
        tosca_path = [selpath, '\', extractSessions{currentDay}];
        video_path = [f{1}, '\', f{2}, '\Behavior_videos\',f{4}, '\', extractSessions{currentDay}];
        t = analyze_session_pupil(video_path, tosca_path);
        disp(strcat("Session ",num2str(currentDay)));
        pupil.sessionNum = [pupil.sessionNum, t.sessionNum];
        pupil.diameter = [pupil.diameter; t.diameter];
        
     
       
    end
   

   
    save(filepath, 'pupil');
end