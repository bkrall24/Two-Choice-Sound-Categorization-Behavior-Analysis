function [percents, ids] = calculate_means(data, stimulus, stimulus_choice)
    
    % Rebecca Krall
    %
    % This function is designed to take data and calculate the mean for
    % some condition
    
    if nargin < 3
        stimulus_choice = 'all';
    end      
            

    [groups, ids] = findgroups(stimulus);    
    stimulus_chunks = splitapply(@(x) {[x]}, data, groups);
    
    
    % I'm going to hard code this for the AM frequencies
    if stimulus_choice == "all"
        
        percents = cellfun(@nanmean, stimulus_chunks);
        
    elseif stimulus_choice == "easy"
        
        easy = ismember(ids, [2,2.82842700000000 22.6274170000000,32]);        
        percents(1) = nanmean(cat(2, stimulus_chunks{easy}));
        
        hard = ismember(ids, [4,5.65685400000000,11.3137080000000,16]);
        percents(2) = nanmean(cat(2, stimulus_chunks{hard}));
        
        indiscrim = ids == 8;
        percents(3) = nanmean(cat(2, stimulus_chunks{indiscrim}));
        ids = ["Easy", "Hard", "Indiscriminable"];
        
    elseif stimulus_choice == "distance"
       
        percents(1) = nanmean(cat(2, stimulus_chunks{ismember(ids, [2 32])}));
        percents(2) = nanmean(cat(2, stimulus_chunks{ismember(ids, [2.82842700000000 22.6274170000000])}));
        percents(3) = nanmean(cat(2, stimulus_chunks{ismember(ids, [4 16])}));
        percents(4) = nanmean(cat(2, stimulus_chunks{ismember(ids, [5.65685400000000,11.3137080000000])}));
        percents(5) = nanmean(cat(2, stimulus_chunks{ismember(ids, [8])}));
        ids = [2, 1.5, 1, 0.5, 0];
        
    elseif stimulus_choice == "low"
        
        low = ismember(ids, [2,2.82842700000000, 4,5.65685400000000,]);
        percents(1) = nanmean(cat(2, stimulus_chunks{low}));
        
        high = ismember(ids, [11.3137080000000,16, 22.6274170000000,32]);
        percents(2) = nanmean(cat(2, stimulus_chunks{high}));
        
        indiscrim = ids == 8;
        percents(3) = nanmean(cat(2, stimulus_chunks{indiscrim}));
        ids = ["Low", "High", "Category Boundary"];
    else        
        percents = nanmean(data);
        ids = "overall";
    end
        
    
    
    
    
    

        
    
    

end