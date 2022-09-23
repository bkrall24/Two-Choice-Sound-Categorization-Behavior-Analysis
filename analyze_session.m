function session =  analyze_session(selpath)

    % Rebecca Krall 
    %
    % This function analyzes a tosca session of behavior. Its used in
    % conjuction with analyze_animal to create a data structure that
    % concatenates behavioral information across days.
    % 
    % Inputs:
    %   selpath -  folder path that can be passed in to indicate what 
    %       session folder to analyze. If no arguments are passed into the 
    %       function, it will prompt user to choose a folder.
    %
    % Outputs: 
    %   session - struct of arrays whose length is equal to the number of
    %       trials in that session. Each index provides the relevant 
    %       information for  a given trial
    %      
    %   

    
    if nargin == 0
        startPath = 'W:\Data\2AFC_Behavior';
        selpath = uigetdir(startPath);
    end
    
    % extract the number of runs to analyze from the .ini file
    iniFile = dir2(selpath, '.ini', '/s');
    openFile = fopen(iniFile{1}, 'r');
    iniData = fscanf(openFile, '%s');
    fclose(openFile);
    numberOfRuns = str2num(cell2mat(regexp(iniData, '\d*', 'Match')));
    
   
    % Instead of iterating through the folder to find all the Run#.txt
    % files, its simpler to use the naming conventions of the files and
    % just generate a list of strings that have the same names as your
    % target files
    f = split(selpath, ["\"," "]);
    fnString = [f{end-2},'-',f{end-1},f{end},'-Run'];
    for n = 1:numberOfRuns
        targetFiles(n) = {[selpath,'\',fnString,num2str(n),'.txt']};
    end
    
    
    % Initialize the arrays for saving the data
    session.runID =[];
    session.stimulus = [];
    session.rxnTime = [];
    session.choice =[];
    session.parameter = [];
    session.sessionNum = [];
    session.LED = [];
    session.target = [];
  
    
    % Iterates through each file in the session - there is 1 file for each
    % run
    for analyzeNum = 1:length(targetFiles)

        % tosca_read_run returns two structures, d and p which contain data
        % and parameters respectively. This code assumes if tosca_read_run
        % fails it is because there is a mismatch between the strings
        % generated earlier and the actual run files contained in the
        % folder. 
        try            
            [d,p] = tosca_read_run(targetFiles{analyzeNum});                    
        catch
            disp(strcat(targetFiles{analyzeNum}," not contained in folder"));
            d = [];
            p = [];
        end
       
        if ~isempty(d)    
            %disp(strcat('analyzing file :',targetFiles{analyzeNum}));
            
            % d is a 1 x n cell array where n = the number of trials in
            % that run. This iterates through each trial and pulls out
            % specific information for each
            for trial = 1:length(d)
                                
                % This code is an attempt to extract the stimulus in a way
                % that's a bit agnostic to the Tosca setup. I think its
                % still not perfect. Notably, if you rename the cue in
                % Tosca it won't work.
                %   signalNames = fieldnames(d{1,trial}.Cue); Can be used
                %   and replace Signal below with (signalNames{1}).
                %   However, in dualspout pavlovian trials, this causes an
                %   error because you pull out the timeout value instead of
                %   the signal value.
                try
                    signalName = fieldnames(d{1,trial}.Cue.Signal);
                    signalVar = fieldnames(d{1,trial}.Cue.Signal.(signalName{1}));
                    stimulus = d{1,trial}.Cue.Signal.(signalName{1}).(signalVar{1});
                catch
                    stimulus = 0;
                end
                session.stimulus = [session.stimulus, stimulus];
                session.sessionNum = [session.sessionNum, str2num(f{end})];
                session.runID = [session.runID, analyzeNum]; 
                session.choice = [session.choice, string(d{1,trial}.Result)];
                
                try
                    session.target = [session.target, d{1,trial}.TargetSpout];
                catch
                    session.target = [session.target, nan];
                end
                
                parameterName = string(p.Info.Parameter_file);
                session.parameter = [session.parameter, parameterName];
               
                session.rxnTime = [session.rxnTime, d{1,trial}.Rxn_time_ms];
                
                try
                    session.LED = [session.LED, d{1, trial}.Start.Timeout.LED.Enabled];
                catch
                    session.LED = [session.LED, 0];
                end
                                              
            end
        else
            disp([targetFiles{analyzeNum},' is empty']);
        end
   
        
    end
   
    % The lickInfo matrix is a quick reference to determine the decision on
    % each trial without parsing strings. 
    session.lick(1,:) = contains(session.choice, 'High Hit') | contains(session.choice, 'Right Hit'); 
    session.lick(2,:) = contains(session.choice, 'Low Hit') | contains(session.choice, 'Left Hit');
    session.lick(3,:) = contains(session.choice, 'High Miss') | contains(session.choice, 'Right Miss');
    session.lick(4,:) = contains(session.choice, 'Low Miss') | contains(session.choice, 'Left Miss');
    session.lick(5,:) = contains(session.choice, 'No Go');
    
    % Save space by making things logical arrays when possible
    session.target = logical(session.target - 1);
    session.LED = logical(session.LED);

end