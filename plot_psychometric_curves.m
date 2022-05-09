function curves = plot_psychometric_curves(name, bins, conditions)
    
    % Rebecca Krall
    %
    % This function takes a single animal behavior and fits and plots
    % psychometric curves for each bin (default bin is a single session).
    % Additionally multiple psychometric curves can be fit and plotted for
    % each bin. 
    %
    % Inputs:
    %   name - struct, output of analyze_animal
    %   bins - numeric array, array of bin_ids for each trial 
    %   conditions - boolean or numeric array, array of condition ids for
    %       each trial for the different curves to be fit
    %
    % Outputs:
    %   curves - N x M array of structs, output of fit_psychometric_curve

    if isempty(bins)
        bins = name.sessionNum;
    end
    
    
    

    high_side = mode(name.target(name.stimulus == 32));
    colors = colororder;
    
    figure
    for i = unique(bins)
        conds = unique(conditions(bins == i));
        nexttile
        for j = 1:length(conds)
            
            trial_choice = (bins == i) & conditions == conds(j);            
            [stim_groups, stimuli] = findgroups(name.stimulus(trial_choice));
            lick = name.lick(1:4,trial_choice);    
            lick_right = splitapply(@(x) sum(x([1,4],:), 'all')/sum(x, 'all'), lick, stim_groups);
            
            if high_side == 0
                lick_right = 1 - lick_right;
            end
            
            if sum(~isnan(lick_right)) > 3
                psych = fit_psychometric_curve(stimuli(~isnan(lick_right)), lick_right(~isnan(lick_right)), true, colors(j,:));
                curves(i,j) = psych;
            end
                      
            
        end
    end
    
    
       
end