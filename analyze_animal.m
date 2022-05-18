function animal = analyze_animal(selpath)
    
    % Rebecca Krall 01/18/21
    
    % This function analyzes tosca two-choice lick behavior. It is used in
    % conjuction with analyze_session to create a data structure that
    % concatenates behavioral information across days. This assumes a
    % Tosca-based folder structure in which each animal has a folder with
    % subfolders for each behavioral session. 
    
    % Inputs:
    %   selpath - optional path input that indicates what folder will be
    %       analyzed. If not passed, the user is prompted to choose
    %
    % Outputs:
    %   animal - a data structure containing relevant information from
    %       each trial and day of behavior

    if nargin == 0
        startPath = 'W:\Data\2AFC_Behavior';
        selpath = uigetdir(startPath);
    end
    
    
    % Make a new filename using the name of the directory you select. If
    % customizing different 'analyze_animal' functions, change the filepath
    % string to differentiate between different types of analysis
    f = split(selpath, ["\"]);
    filepath = [selpath,'\','analyze_animal_',f{end},'.mat'];
    
    % Checks to see if file was already generated, if so, it loads the
    % data as well as identifying which sessions have already been
    % analyzed. If not, it initalizes the variables to be saved. 
    if isfile(filepath)
        load(filepath, 'animal');
        loadedSessions = unique(animal.sessionNum);
        disp(strcat("Loading data from ", filepath));
    else
        loadedSessions = 'nan';
        animal.runID = [];
        animal.stimulus = [];
        animal.rxnTime = [];
        animal.choice =[];
        animal.parameter = [];
        animal.sessionNum = [];
        animal.LED = [];
        animal.target = [];   
        animal.lick = [];
        disp(strcat("No file exists, creating file ",filepath));
    end
    
    % Pulls out all the names of the folders in the directory you chose to
    % determine how many possible sessions exist. Then makes a variable
    % containing all the filenames
    sessionFolders = dir(selpath);
    filenames = extractfield(sessionFolders, 'name');
    filenames = filenames(contains(filenames, 'Session'));
  
    
    % dir puts the filenames in alphabetical order, so you need to re-sort
    % them based on the session number to ensure you're keeping things
    % chronological
    sessionNum = cellfun(@str2num, (regexp(cell2mat(filenames), '\d*', 'Match')));
    [ns,sortIdx] = sort(sessionNum,'ascend');
    filenames = filenames(sortIdx);
    
    % Determines which of those folders to analyze by comparing the list
    % from the folder to the list from the data file
    extractSessions = filenames( ~ismember(ns, loadedSessions));
    
    
    % Iterates through each folder that has not been analyzed and pulls out
    % the data using analyze_session then concatenates it to the end of the
    % data structure. 
    % NOTE: This code assumes that you only add sessions chronologically.
    % So it always adds to the end of the structure. If there are cases
    % when you would add an earlier unanalyzed session, the code will still
    % work but the trials would no longer appear in chronological order.
    for currentDay = 1:length(extractSessions)
       
        inputPath = [selpath, '\', extractSessions{currentDay}];
        session = analyze_session(inputPath);
        fields = fieldnames(session);
        for i = 1:length(fields)
            past = getfield(animal, fields{i});
            new = [past, getfield(session, fields{i})];
            animal = setfield(animal, fields{i}, new);
        end
       
    end
   
   
    save(filepath, 'animal');
    
end