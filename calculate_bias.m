function bias = calculate_bias(lick, highSide)
    
    if highSide == 1
        lefts = sum(lick([2,3],:), 'all');
        rights = sum(lick([1,4],:), 'all');
    else
        rights = sum(lick([2,3],:), 'all');
        lefts = sum(lick([1,4],:), 'all');
    end
    bias = (lefts - rights)/(lefts + rights);
end