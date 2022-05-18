function rates = get_performance_rates(name, bins, conditions, stimulus_choice, plot_choice)

    if isempty(bins)
        bins = name.sessionNum;
    end
    
    if nargin < 4
        stimulus_choice = 'all';
    end
    if nargin < 5
        plot_choice = 'Hits';
    end

   
    colors = colororder;
    colors = [colors; colors; colors; colors; colors];
    
    if stimulus_choice == "all"
        s = [2,2.82842700000000,4,5.65685400000000,8,11.3137080000000,16,22.6274170000000,32];
    elseif stimulus_choice == "easy"
        s = ["Easy", "Hard", "Indiscriminable"];
    elseif stimulus_choice == "distance"
        s = [2, 1.5, 1, 0.5, 0];
    elseif stimulus_choice == "low"
        s = ["Low", "High", "Category Boundary"];
    else
        s = ["overall"];
    end
    
    
    b = unique(bins);
    for i = 1:length(b)
        conds = unique(conditions(bins == b(i)));
        
        for j = 1:length(conds)

            trial_choice = (bins == b(i)) & conditions == conds(j);
            [p, stims] = calculate_percentages(name.lick(:, trial_choice), name.stimulus(trial_choice), stimulus_choice, plot_choice);
            rates(ismember(s, stims),i,j) = p;
            rates(~ismember(s, stims),i,j) = nan;

        end
    end
    
    
end