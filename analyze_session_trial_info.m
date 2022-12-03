function tInfo = analyze_session_trial_info(selpath)
    
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
    
    % These are all the data that will be saved as a long array containing
    % a point for each trial across the session, which can be concatenated
    % together across sessions
    tInfo.lick1 = [];
    tInfo.lick2 = [];
    tInfo.h2o1 = [];
    tInfo.h2o2 = [];
    tInfo.sessions = [];
    tInfo.good_trials = [];
    
    % Iterates through each file in the session - there is 1 file for each
    % run
    for analyzeNum = 1:length(targetFiles)
        
        % Try to generate the timing log to get the exact time the cue
        % comes on for each trial
        try
            l = tosca_create_log(targetFiles{analyzeNum}); 
        catch
            l = [];
            disp(strcat(targetFiles{analyzeNum}," not contained in folder / CREATE LOG errored"));
        end
       
        % Try to generate the information for each trial using the run.txt
        % file. Note this is critical for generating the lick rasters, so
        % it will be impossible to get this information if this function
        % fails
        try
            [d,p] = tosca_read_run(targetFiles{analyzeNum});
        catch
            d = [];
            p = [];
            disp(strcat(targetFiles{analyzeNum}," not contained in folder / READ RUN errored"));
        end
        
        
        % Assuming tosca_read_run works, you next iterate through the
        % trials and get the raster information for each trial.
        for trial = 1:length(d)

            try
                s = tosca_read_trial(p, d, trial);
            catch
                s = [];
                disp(strcat("Trial ", num2str(trial)," failed tosca_read_trial"));
            end       

            
            try
                states = {l.trials{1,trial}.states.name};
                cueState = find(cellfun(@isequal, states, repmat({'Cue'}, size(states))));
                cue_start = l.trials{1, trial}.states(cueState).start;
                relativeTiming = s.Time_s - cue_start;
            catch
                try  
                    state_ind = find(s.State_Change);
                    cue_start_ind = state_ind(find(diff(state_ind) > 1, 1, 'first')+1);
                    cue_start = s.Time_s(cue_start_ind);
                    relativeTiming = s.Time_s - cue_start;
                catch
                    relativeTiming = [];
                end
            end
            
            if ~isempty(relativeTiming)
               
                remove_ind = (diff(relativeTiming) > 0);
                [v, w] = unique( relativeTiming(remove_ind), 'stable' );
                duplicate_indices = setdiff( 1:numel(relativeTiming(remove_ind)), w );
                remove_ind(duplicate_indices)= 0;
                

                % Resample the data such that you pull out 1 second
                % before the start of the cue (in Becca's AM and Tone
                % Cloud parameter files, the sound comes on 0.5 seconds
                % after the start of the Cue) and 3 seconds after.
                % NOTE: this resamples the data with interpl- therefore
                % you might end up with values that are not 1 or 0.
                % I'm going to cast these as logicals, so there might
                % be some minor minor data loss where one sample (1/500
                % of a second) has the wrong value.
                resample = [-1:1/500:3];
                try
                    lick1 = interp1(relativeTiming(remove_ind), s.Lickometer_1(remove_ind), resample);
                
                    lick1(isnan(lick1)) = 0;
                    lick2 = interp1(relativeTiming(remove_ind), s.Lickometer_2(remove_ind), resample);
                    lick2(isnan(lick2)) = 0;
                    h2o1 = interp1(relativeTiming(remove_ind), s.H2O(remove_ind), resample);
                    h2o1(isnan(h2o1)) = 0;
                    h2o2 = interp1(relativeTiming(remove_ind), s.H2O2(remove_ind), resample);
                    h2o2(isnan(h2o2)) = 0;


                    tInfo.h2o1 = [tInfo.h2o1; logical(h2o1)];
                    tInfo.h2o2 = [tInfo.h2o2; logical(h2o2)];
                    tInfo.lick1 = [tInfo.lick1; logical(lick1)];
                    tInfo.lick2 = [tInfo.lick2; logical(lick2)];
                    tInfo.sessions = [tInfo.sessions, str2num(f{end})];
                    tInfo.good_trials = [tInfo.good_trials, true];
                catch
                    tInfo.h2o1 = [tInfo.h2o1; false(1, 2001)];
                    tInfo.h2o2 = [tInfo.h2o2; false(1, 2001)];
                    tInfo.lick1 = [tInfo.lick1; false(1, 2001)];
                    tInfo.lick2 = [tInfo.lick2; false(1, 2001)];
                    tInfo.sessions = [tInfo.sessions, str2num(f{end})];
                    tInfo.good_trials = [tInfo.good_trials, false];
                end
            else
                tInfo.h2o1 = [tInfo.h2o1; false(1, 2001)];
                tInfo.h2o2 = [tInfo.h2o2; false(1, 2001)];
                tInfo.lick1 = [tInfo.lick1; false(1, 2001)];
                tInfo.lick2 = [tInfo.lick2; false(1, 2001)];
                tInfo.sessions = [tInfo.sessions, str2num(f{end})];
                tInfo.good_trials = [tInfo.good_trials, false];
            end
            
            
            
            
            
            
            
        end  
          
    end
end
        
            
       
        
        
    
   

