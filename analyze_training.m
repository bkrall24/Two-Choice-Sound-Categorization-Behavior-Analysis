function training = analyze_training(name, save_choice)

    % Rebecca Krall
    %
    % This function pulls out key points about the training trajectory of a
    % given animal
    %
    % Inputs:
    %   name - structure, output of analyze_animal
    %
    % Outputs:
    %   training - structure containing relevant information about the
    %   training
    
    
    % Pull out relevent boolean arrays
    dualspout = contains(name.parameter, 'dualspout_op');
    
    
    % Only look at dualspout trials to get the stimuli because I have wonky
    % code for determining the stimulus value that should be changed but
    % alas, has not been.
    stim = unique(name.stimulus(dualspout));
    
    % Identify easy stimuli
    if mode(contains(name.parameter, 'AM')) == 1
        easyLow = name.stimulus == 2 | name.stimulus == 2.828427;
        easyHigh = name.stimulus == 22.627417 | name.stimulus == 32;        
        discrim = name.stimulus ~= 8;
    elseif mode(contains(name.parameter, 'TC')) == 1
        easyLow = name.stimulus == 8000 | name.stimulus == 9513.65692000000;        
        easyHigh = name.stimulus == 26908.6852880000 | name.stimulus == 32000;
        discrim = name.stimulus ~= 16000;
    else
        easyLow = name.stimulus == min(stim) | name.stimulus == min(stim(stim~= min(stim)));
        easyHigh = name.stimulus == max(stim) | name.stimulus == max(stim(stim~= max(stim)));
        discrim = name.stimulus ~= stim(5);
    end    
    easy = easyLow | easyHigh;

    
    % We start optogenetics when the animal is getting => 60% correct over
    % 200 dualspout easy trials. This calculates the exact trial, however
    % we generally will wait to introduce optogenetic trials till the next
    % session after this threshold is passed.
    training.trials_opto = get_trial_number_at_threshold(name, 0.6, dualspout & easy & ~(name.LED));
    training.days_opto = name.sessionNum(training.trials_opto);
    
    % An animal is 'proficient' and psychometric/hard sounds are introduced
    % once the are getting => 85% correct over 200 dualspout easy trials.
    training.trials_proficient = get_trial_number_at_threshold(name, 0.85, dualspout & easy & ~(name.LED));
    training.days_proficient = name.sessionNum(training.trials_proficient);
    
    % This is a new expert threshold. Its when the animal passes 85% on all
    % hard, discriminable trials (i.e. not easy and not category boundary)
    training.trials_expert = get_trial_number_at_threshold(name, 0.75, dualspout & ~(name.LED) & discrim & ~easy);
    training.days_expert = name.sessionNum(training.trials_expert);
    
   
    trial_ref = 1:length(name.lick);
    go = name.lick(1,:) | name.lick(2,:) | name.lick(3,:) | name.lick(4,:);
    
    select_easy = easy & ~(name.LED) & go & dualspout;
    easy_hits = name.lick(1,select_easy )|name.lick(2,select_easy );
    training.easy_x = trial_ref(select_easy);
    training.easy_trajectory = movsum(easy_hits, [200, 0])./200;
    
    
    select_discrim = discrim & ~(name.LED) & go & dualspout;
    hits_discrim = name.lick(1,select_discrim) | name.lick(2,select_discrim);
    training.discrim_x = trial_ref(select_discrim);
    training.discrim_trajectory = movsum(hits_discrim, [200, 0])./200;
    
    select_hard = discrim & ~easy & ~(name.LED) & go & dualspout;
    hits_hard = name.lick(1, select_hard)|name.lick(2, select_hard);
    training.hard_x = trial_ref(select_hard);
    training.hard_trajectory = movsum(hits_hard, [200, 0])./200;
    
    if nargin > 1
        if save_choice
            startPath = 'W:\Data\2AFC_Behavior';
            selpath = uigetdir(startPath);
            f = split(selpath, ["\"]);
            filepath = [selpath,'\','analyze_training_',f{end},'.mat'];
            save(filepath, 'training')
        end
    end

end