function threshold_trial = get_trial_number_at_threshold(name, threshold, trial_boolean, sigma, nogo_threshold)

    % Rebecca Krall
    %
    % This function takes behavioral data and determines the trial number
    % when the animal passed a given threshold in a given subset of trials.
    %
    % Inputs:
    %   name - structure, output of analyze_animal
    %   threshold - double, the proportion of trials that must be correct
    %       to pass the threshold of trained
    %   trial_boolean - a boolean array, same length as arrays in name,
    %       that indicates which trials to calculate the success rate on.
    %       Optional, if no value is passed then the threshold is
    %       calculated on dualspout operant go trials.
    %   sigma - double, indicates the rolling window over which to
    %       calculate success rate
    %   nogo_threshold - boolean, if true, then it finds the trial where the
    %       threshold is passed after the animal drops below the rate of
    %       20% no gos. 
    
    % Outputs:
    %   threshold_trial - trial number (out of all possible trials) where
    %       animal passed threshold. Note, I have the additional condition
    %       where the no go rate has to drop below 20% over the same sigma
       

    if nargin < 3
        dualspout = contains(name.parameter, 'dualspout_op');
        trial_boolean = dualspout;
    end
    
    if nargin < 4
        sigma = 200;
    end
    
    if nargin < 5
        nogo_threshold = true;
    end
    
    go = name.lick(1,:) | name.lick(2, :) | name.lick(3,:) | name.lick(4, :);
    
    % Create a reference array 
    trial_num = 1:length(name.lick);
    trial_ref_go = trial_num(trial_boolean & go);
    
    % Determine the success rate over the last sigma trials
    hits = name.lick(1,trial_boolean & go) | name.lick(2, trial_boolean & go);
    correct = movsum(hits, [sigma, 0])./sigma;
    
    if nogo_threshold
        trial_ref_nogo = trial_num(trial_boolean);
        nogos = name.lick(5, trial_boolean);
        nogo = movsum(nogos,[sigma, 0])./sigma;
        going = trial_ref_nogo(find(nogo < 0.20, 1, 'first'));
        thresh = trial_ref_go((correct > threshold));
        threshold_trial = min(thresh(thresh > going));
    else
        threshold_trial = min(trial_ref_go((correct > threshold)));
    end
    
    
end
