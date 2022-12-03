
function [percents, ids] = calculate_percentages(lick, stimulus, stimulus_choice, return_choice)
    
    % Rebecca Krall
    %
    % This function is designed to take the lick matrix generated in
    % analyze_animal and calculate some metric
    % (i.e. % Hits, % Low, % High, % No Go) over specific trials and
    % stimuli presentations
    %
    % Inputs:
    %   lick - 5 x N logical matrix, lick fieldname in output of
    %   analyze_animal
    %   stimulus - 1 x N numerical matrix, stimuli for each trial n in N
    %   stimulus_choice - string, "all", "easy", "distance", or "low" -
    %       indicates the how to bin trials when calcuating percentages
    %           all: every stimulus
    %           easy: easy, hard, and indiscriminable 
    %           distance: calculated as distance to category boundary
    %           low: low, high and category boundary
    %           anything else: just returns the percent over all trials
    %   return_choice: string, "Hits", "Left" or "No Go" - indicating what
    %       you want to calculate.
    
    if nargin < 3
        stimulus_choice = 'all';
    end
      
    if nargin < 4
        return_choice = 'Hits';
    end
                
   
    if return_choice == "Hits"
        num = [1,2];
        denom = [1:4];
    elseif return_choice == "Left"
        num = [2,3];
        denom = [1:4];
    elseif return_choice == "No Go"
        num = [5];
        denom = [1:5];
    end
    
    try
        [groups, ids] = findgroups(stimulus);
        numerator = splitapply(@(x) sum(x(num,:), 'all'), lick, groups);
        denominator = splitapply(@(x) sum(x(denom,:), 'all'), lick, groups);
    catch
        numerator = []
        denominator = [];
    end
    
    
    % I'm going to hard code this for the AM frequencies
    if stimulus_choice == "all"
        
        percents = numerator./denominator;
        
    elseif stimulus_choice == "easy"

        percents(1) = sum(numerator(ismember(ids, [2,2.82842700000000 22.6274170000000,32])))./sum(denominator(ismember(ids, [2,2.82842700000000 22.6274170000000,32])));
        percents(2) = sum(numerator(ismember(ids, [4,5.65685400000000,11.3137080000000,16])))./sum(denominator(ismember(ids, [4,5.65685400000000,11.3137080000000,16])));
        percents(3) = sum(numerator(ismember(ids, [8])))./sum(denominator(ismember(ids, [8])));

        ids = ["Easy", "Hard", "Indiscriminable"];
        
    elseif stimulus_choice == "distance"
        
        percents(1) = sum(numerator(ismember(ids, [2 32])))./sum(denominator(ismember(ids, [2 32])));
        percents(2) = sum(numerator(ismember(ids, [2.82842700000000 22.6274170000000])))./sum(denominator(ismember(ids, [2.82842700000000 22.6274170000000])));
        percents(3) = sum(numerator(ismember(ids, [4 16])))./sum(denominator(ismember(ids, [4 16])));
        percents(4) = sum(numerator(ismember(ids, [5.65685400000000,11.3137080000000])))./sum(denominator(ismember(ids, [5.65685400000000,11.3137080000000])));
        percents(5) = sum(numerator(ismember(ids, [8])))./sum(denominator(ismember(ids, [8])));
        ids = [2, 1.5, 1, 0.5, 0];
        
    elseif stimulus_choice == "low"
        
        percents(1) = sum(numerator(ismember(ids, [2,2.82842700000000, 4,5.65685400000000,])))./sum(denominator(ismember(ids, [2,2.82842700000000, 4,5.65685400000000,])));
        percents(2) = sum(numerator(ismember(ids, [11.3137080000000,16, 22.6274170000000,32])))./sum(denominator(ismember(ids, [11.3137080000000,16, 22.6274170000000,32])));
        percents(3) =  sum(numerator(ismember(ids, [8])))./sum(denominator(ismember(ids, [8])));
        ids = ["Low", "High", "Category Boundary"];
    else        
        percents = sum(numerator)./sum(denominator);
        ids = "overall";
    end
        
    
    
    
    
    

        
    
    

end