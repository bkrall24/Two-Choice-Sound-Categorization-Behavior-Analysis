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
    %   curves - N x M array of structs, output of fit_psychometric_curve,
    %   N = number of bins, M = number of conditions. Struct is empty if no
    %   trials fit the condition

    if isempty(bins)
        bins = name.sessionNum;
    end
    
    
    

    high_side = mode(name.target(name.stimulus == 32));
    colors = colororder;
    colors = [colors; colors; colors; colors; colors];
    
    figure
    b = unique(bins);
    for i = 1:length(b)
        conds = unique(conditions(bins == b(i)));
        nexttile
        for j = 1:length(conds)
            
            trial_choice = (bins == b(i)) & conditions == conds(j);
            highSide = mode(name.target(name.stimulus == 2));
            [xAxis, yData, ~] = generate_psych_data(name.lick(:, trial_choice), name.stimulus(trial_choice), highSide);
            
            if sum(~isnan(yData)) > 3
                psych = fit_psychometric_curve(xAxis(~isnan(yData)), yData(~isnan(yData)), true, colors(j,:));
                curves(i,j) = psych;
            end
                      
            
        end
        title(i)
    end
    
    
       
end