function pupil = analyze_session_pupil(video_path, tosca_path)
    
    % gets the log and dlc files from the video data
    log_files = dir2(video_path, '.log', '/s');    
    dlc_files = dir2(video_path, '.csv', '/s');
    
    try
        dlc_files = dlc_files(contains(dlc_files, 'filtered'));
        log_id = cellfun(@split, log_files, repmat({["\","."]}, size(log_files)), 'UniformOutput', false);
        log_id = cellfun(@(x){[x(6)]}, log_id);
        log_id = [log_id{:}];
    catch
        disp(strcat("oops no DLC files in ",tosca_path))
    end
    
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
    pupil.sessions = [];
    

    
    % Iterates through each file in the session - there is 1 file for each
    % run
    for analyzeNum = 1:length(targetFiles)
        
        %disp(strcat("Run num: ",num2str(analyzeNum)));
        
        tosca_run = targetFiles{analyzeNum};
        tosca_compare = split(tosca_run, ["\","."]);
        tosca_compare = tosca_compare(6);
        
        
        % First see if there are 
        try 
            has_pupil = cellfun(@isequal, log_id, repmat(tosca_compare, size(log_id)));
            pupil_run = log_files{has_pupil};
            pupil_info = readtable(pupil_run);
            pupil_start = find(contains(pupil_info{:,4}, 'Trial'), 1, 'first');
            
            pupil_info = pupil_info(pupil_start:end,:);
            pupil_files = pupil_info{contains(pupil_info{:,4}, 'File'),4};
            
        catch
            pupil_files = nan;
            disp(strcat("There are no pupil files for ",tosca_compare))
        end
        
        if ~isnan(pupil_files)
            try
                [d,p] = tosca_read_run(targetFiles{analyzeNum});
            catch
                disp(strcat(targetFiles{analyzeNum}," not contained in folder"));
                d = [];
                p = [];
            end

            if ~isempty(d)
                try
                    l = tosca_create_log(d, p); 
                catch
                    disp(strcat("Tosca_create_log failed for ", tosca_path));
                end

                states = [p.Tosca.Flowchart.State];
                cueState = find(contains({states.Name}, 'Cue'));

                if length(d) > length(pupil_files)
                    warning('More tosca trials than pupil trials')
                elseif length(d) < length(pupil_files)
                    warning('More pupil trials than tosca trials')
                    %b_file = contains(pupil_files, );
                    file_numbers = extract(pupil_files, digitsPattern);
                    file_numbers = cellfun(@str2num, file_numbers);
                    [~, c_files, ~] = unique(file_numbers);
                    pupil_files = pupil_files(c_files);
                    %pupil_files = pupil_files(~b_file);
                end

                for trial = 1:length(d)
                    %disp(strcat("Trial num: ",num2str(trial)))
                    try
                        file_id = pupil_files{trial};
                        file_num = file_id(regexp(file_id, '\d'));
                        current_file = [tosca_compare{1}, '.', file_num];
                        %pupil_trial = dir2(video_path, ['*',current_file,'*'], '.csv', '/s');
                        pupil_trial = dlc_files(contains(dlc_files, current_file));

                        if ~isempty(pupil_trial)
                            pupil_trial = pupil_trial{1};
                        end

                        video_start = find(contains(pupil_info{:,4}, pupil_files(trial)));
                        if length(video_start) > 1
                            video_start = video_start(1);
                        end

                        if trial ~= length(d)
                            video_end = find(contains(pupil_info{:,4}, pupil_files(trial+1)))-2;
                        else
                            video_end = height(pupil_info);
                        end

                        video_trace = pupil_info(video_start:video_end,:);
                        pupil_trace = extract_pupil_behavior(pupil_trial,0, 0.8);
                    catch
                       pupil_trace = nan;
                    end


                    try
                        %s = tosca_read_trial(p, d, trial);
                        cue_state = find(ismember({l.trials{1, trial}.states.name}, {'Cue'}));
                        %cue_start = l.trials{1, trial}.states(cue_state).start;
                        state_starts = find(video_trace{:,3} == -1);
                        cue_start_pupil = video_trace{state_starts(cue_state),2};
                        relativeTiming = video_trace{video_trace{:,3} ~= -1,2} - cue_start_pupil;
                        %[~,x] = min(abs(relativeTiming));
                        %sampling_rate = round(mean(1./diff(relativeTiming)));

                        resample = [-1: 1/500: 3];
                        pupil_resampled = interp1(relativeTiming, pupil_trace, resample);
                        %pupil.relativeTiming = [pupil.relativeTiming; relativeTiming(x-sampling_rate:x+sampling_rate*3)'];
                        pupil.diameter = [pupil.diameter; pupil_resampled];

                    catch

                       % pupil.relativeTiming = [pupil.relativeTiming; nan(1,2001)];
                        pupil.diameter = [pupil.diameter; nan(1,2001)];

                    end
                    pupil.sessions = [pupil.sessions, str2num(f{end})];

                end
            else
                disp([targetFiles{analyzeNum},' is empty']);
            end

        end
    end
    pupil.diameter = process_pupil_matrix(pupil.diameter);

end