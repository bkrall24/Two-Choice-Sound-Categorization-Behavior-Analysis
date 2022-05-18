function bin_id = generate_bins(num_trials, bin_def)
    
    % Rebecca Krall
    %
    % This function is designed to easily generate a reference array
    % indicating a bin number for each trial based on either a bin size or
    % a percent towards a given trial.
    
    % Inputs:
    %   num_trials - double, the total number of trials you're binning
    %       over
    %   bin_def - array of doubles with following options:
    %       -[a,b] where a < 1, b > 1, a is the percent of trials to the
    %           threshold, b  
    %       - [a], where a < 1, a is the percent of trials towards the
    %           last trial
    %       - [a], where a > 1 and is the number of trials per bin
    
   
    if length(bin_def) == 2
        bin_percent = bin_def(1);
        threshold = bin_def(2);
        bin_size = round(bin_percent * threshold);
    elseif length(bin_def) == 1
        if bin_def < 1
            bin_percent = bin_def;
            threshold = num_trials;
            bin_size = round(bin_percent * threshold);
        else
            bin_size = bin_def;
        end
    end
    
    num_bins = floor(num_trials/bin_size);


    bin_id = NaN(1,num_trials);
    temp_array = repmat([1:num_bins], [bin_size ,1]);
    bin_id(1:numel(temp_array)) = temp_array;

end
    