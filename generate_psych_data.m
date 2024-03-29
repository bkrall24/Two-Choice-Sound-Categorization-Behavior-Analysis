function [xAxis, yData, errorbars] = generate_psych_data(lick, stimuli, highSide)

    [stim_groups, stimuli] = findgroups(stimuli);
    hits_stim = splitapply(@(x) sum(x([1,4],:)', 'all'), lick, stim_groups);
    trials_stim = splitapply(@(x) sum(x(1:4,:), 'all'), lick, stim_groups);
    
    [yData, errorbars] = binofit(hits_stim, trials_stim);
    if highSide
        yData = 1-yData;
        errorbars = 1-errorbars;
    end
    xAxis = stimuli;
    
end