function pupil = analyze_session_pupil(video_path, tosca_path)
    

    % extract the number of runs to analyze from the .ini file
    iniFile = dir2(tosca_path, '.ini', '/s');
    openFile = fopen(iniFile{1}, 'r');
    iniData = fscanf(openFile, '%s');
    fclose(openFile);
    numberOfRuns = str2num(cell2mat(regexp(iniData, '\d*', 'Match')));


    % Instead of iterating through the folder to find all the Run#.txt
    % files, its simpler to use the naming conventions of the files and
    % just generate a list of strings that have the same names as your
    % target files
    f = split(tosca_path, ["\"," "]);
    fnString = [f{end-2},'-',f{end-1},f{end},'-Run'];
    for n = 1:numberOfRuns
        targetFiles(n) = {[tosca_path,'\',fnString,num2str(n),'.txt']};
    end


    % These are all the data that will be saved as a long array containing
    % a point for each trial across the session, which can be concatenated
    % together across sessions
    pupil.diameter = [];
    pupil.sessionNum = [];



    % Iterates through each file in the session - there is 1 file for each
    % run
    for analyzeNum = 1:length(targetFiles)

        % 5.11.22 update to Ken's Tosca files has a tosca_create_log that
        % take into consideration the avi files. Attempting to rely less on
        % try catches for large chunks of code to catch situations where
        % unexpected errors occur
        try
            log = tosca_create_log(targetFiles{analyzeNum}, 'aviFolder', video_path);
        catch
            try
                log = tosca_create_log(targetFiles{analyzeNum});
                disp(strcat("Tosca_create_log with avi failed for ",targetFiles{analyzeNum}))
            catch
                
                % If unable to make a log, I won't be able to align pupil
                % to the trial info. Set log.trials = [] and 
                log.trials = [];
                disp(strcat("Unable to get any log for ",targetFiles{analyzeNum}))
                try
                    [d,~] = tosca_read_run(targetFiles{analyzeNum});
                    for nt = 1:length(d)
                        pupil.diameter = [pupil.diameter; nan(1,2001)];
                        pupil.sessionNum = [pupil.sessionNum, str2num(f{end})];
                    end
                catch
                    warning(strcat("Unable to get log or read_run for ",targetFiles{analyzeNum}));
                    log.trials = [];
                end
                        
            end
        end

        for t = 1:length(log.trials)
            [~,run_name,~] = fileparts(targetFiles{analyzeNum});
            % Determine the name to earch for the DLC file for the given trial  
            try
                video_file = log.trials{1,t}.aviFile;
                [filepath,name,~] = fileparts(video_file);
            catch
                try
                    
                    if t < 10
                        trial_name = strcat('.00',num2str(t));
                    elseif t < 100
                        trial_name = strcat('.0',num2str(t));
                    else
                        trial_name = strcat('.',num2str(t));
                    end
                    name = strcat(run_name,trial_name);
                    filepath = video_path;
                catch
                    filepath = video_path;
                    name = 'SHOULD NOT BE IN HERE';
                    disp(strcat("Create log worked, but failed get DLC filenames: ", targetFiles{analyzeNum}))
                end
            end
            
            
            dlc_files = dir2(filepath, '.csv', strcat(name, '*'), '/s');
            if ~isempty(dlc_files)
                choose_filtered = cellfun(@contains, dlc_files, repmat({'filtered'}, size(dlc_files)));
            else 
                choose_filtered = [];
            end

            if sum(choose_filtered) < 1
                warning(strcat("No filtered DLC files for ",name))     
                
                pupil.diameter = [pupil.diameter; nan(1,2001)];
                pupil.sessionNum = [pupil.sessionNum, str2num(f{end})];
                
            else
            
                if sum(choose_filtered) > 1
                    warning(strcat("? Too many filtered DLC files for ",name))
                    choose_filtered = listdlg('ListString', dlc_files);
                end
            
            
                dlc = dlc_files{choose_filtered};
            
           
                % get the raw pupil traces
                p = extract_pupil_behavior(dlc, 0.6);
                % clean up the raw pupil trace
                p = process_pupil(p);

                % attempt to get the timing simply by looking the struct
                % created with create_log - if the avi folder version
                % failed, then you'll have to get it another way
                try
                    timing = cat(1, log.trials{1,t}.states.tframe);
                catch
                    try
                        [~,fn,~] = fileparts(targetFiles{analyzeNum});
                        log_file = strcat(video_path,'\',fn, '.avi.log');
                        avilog = readtable(log_file);

                        if t < 10
                            target_file = strcat('.00',num2str(t));
                            next_file =  strcat('.00',num2str(t+1));
                        elseif t < 100
                            target_file = strcat('.0',num2str(t));
                            next_file =  strcat('.0',num2str(t+1));
                        else
                            target_file = strcat('.',num2str(t));
                            next_file =  strcat('.0',num2str(t+1));
                        end

                        file_start = find(cellfun(@contains, avilog{:,4}, repmat({strcat('File:',target_file)}, size(avilog{:,4}))))+1;
                        file_end = find(cellfun(@contains, avilog{:,4}, repmat({next_file}, size(avilog{:,4}))))-2;

                        remove = avilog{file_start:file_end,1} == -1;
                        timing = avilog{file_start:file_end,2};
                        timing = timing(~remove);   
                    catch
                        timing = [];
                    end
                end

                % Attempt to generate an array indicating the timing of the
                % pupil data relative to the cue. I don't know if this is the
                % best way to do this moving forward. The cue should always come
                % on at the same time relative to the trial onset, so the
                % 'catch' condition, normalizes based on this expected interval.
                % Notably, the Pav trials only have 1 sec before stim onset,
                % whereas the operant trials have 2 sec.
                try
                    states = {log.trials{1,t}.states.name};
                    cueState = find(cellfun(@isequal, states, repmat({'Cue'}, size(states))));
                    cue_start = log.trials{1, t}.states(cueState).start;
                    relativeTiming = timing - cue_start;
                catch
                    try
                        if contains(log.params.Info.Parameter_file, 'pav')
                            cue_start = log.trials{1,t}.start + 1;
                        else
                            cue_start = log.trials{1,t}.start + 2;
                        end
                        relativeTiming = timing - cue_start;
                    catch
                        relativeTiming = [];
                    end
                end



                if ~isempty(relativeTiming)
                    remove_ind = (diff(relativeTiming) > 0);
                    resample = [-1:1/500:3];
                    try
                        pupil_diameter = interp1(relativeTiming(remove_ind), p(remove_ind), resample);
                    catch
                        disp(strcat("Pupil diameter interpolation failed for ",run_name," trial: ",num2str(t)))
                        pupil_diameter = nan(1,2001);
                    end
                else
                    pupil_diameter = nan(1,2001);
                end

                pupil.diameter = [pupil.diameter; pupil_diameter];
                pupil.sessionNum = [pupil.sessionNum, str2num(f{end})];

            end
        
       

        end
    end
end