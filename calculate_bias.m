function bias = calculate_bias(lick, stimulus, highSide, stimulus_choice)
    
    if highSide == 1
        lefts = lick([2,3],:);
        rights = lick([1,4],:);
    else
        rights = lick([2,3],:);
        lefts = lick([1,4],:);
    end
   % bias = (lefts - rights)/(lefts + rights);
    
    
    
     if nargin < 3
        stimulus_choice = 'all';
     end      
            

    

    
    
    % I'm going to hard code this for the AM frequencies
    if stimulus_choice == "all"
            [groups, ids] = findgroups(stimulus);    
    left_chunks = splitapply(@(x) {[x]}, lefts, groups);
    right_chunks = splitapply(@(x) {[x]}, rights, groups);
        bias = cellfun(@(x,y) (sum(x, 'all')- sum(y, 'all'))/(sum(x, 'all')+ sum(y, 'all')) , left_chunks, right_chunks);
        
    elseif stimulus_choice == "easy"
            [groups, ids] = findgroups(stimulus);    
    left_chunks = splitapply(@(x) {[x]}, lefts, groups);
    right_chunks = splitapply(@(x) {[x]}, rights, groups);
        easy = ismember(ids, [2,2.82842700000000 22.6274170000000,32]);        
        l = sum((cat(2, left_chunks{easy})), 'all');
        r = sum((cat(2, right_chunks{easy})),'all');
        bias(1) = (l-r)/(l+r);
        
        hard = ismember(ids, [4,5.65685400000000,11.3137080000000,16]);
        l = sum((cat(2, left_chunks{hard})), 'all');
        r = sum((cat(2, right_chunks{hard})), 'all');
        bias(2) = (l-r)/(l+r);
        
        indiscrim = ids == 8;
        l = sum((cat(2, left_chunks{indiscrim})), 'all');
        r = sum((cat(2, right_chunks{indiscrim})), 'all');
        bias(3) = (l-r)/(l+r);        
        
        %ids = ["Easy", "Hard", "Indiscriminable"];
        
    elseif stimulus_choice == "distance"
           [groups, ids] = findgroups(stimulus);    
    left_chunks = splitapply(@(x) {[x]}, lefts, groups);
    right_chunks = splitapply(@(x) {[x]}, rights, groups);
        a = ismember(ids, [2,32]);        
        l = sum((cat(2, left_chunks{a})), 'all');
        r = sum((cat(2, right_chunks{a})),'all');
        bias(1) = (l-r)/(l+r);
        
        b = ismember(ids, [2.82842700000000, 22.6274170000000]);        
        l = sum((cat(2, left_chunks{b})), 'all');
        r = sum((cat(2, right_chunks{b})),'all');
        bias(2) = (l-r)/(l+r);
        
        c = ismember(ids, [4, 16]);        
        l = sum((cat(2, left_chunks{c})), 'all');
        r = sum((cat(2, right_chunks{c})),'all');
        bias(3) = (l-r)/(l+r);
        
        d = ismember(ids, [5.65685400000000,11.3137080000000]);        
        l = sum((cat(2, left_chunks{d})), 'all');
        r = sum((cat(2, right_chunks{d})),'all');
        bias(4) = (l-r)/(l+r);
        
        
        e = ids == 8;
        l = sum((cat(2, left_chunks{e})), 'all');
        r = sum((cat(2, right_chunks{e})), 'all');
        bias(5) = (l-r)/(l+r);        
        
        
        
        %ids = [2, 1.5, 1, 0.5, 0];
        
    elseif stimulus_choice == "low"
            [groups, ids] = findgroups(stimulus);    
    left_chunks = splitapply(@(x) {[x]}, lefts, groups);
    right_chunks = splitapply(@(x) {[x]}, rights, groups);
        low = ismember(ids, [2,2.82842700000000, 4,5.65685400000000,]);
        l = sum((cat(2, left_chunks{low})), 'all');
        r = sum((cat(2, right_chunks{low})),'all');
        bias(1) = (l-r)/(l+r);
        
        
        high = ismember(ids, [11.3137080000000,16, 22.6274170000000,32]);
        l = sum((cat(2, left_chunks{high})), 'all');
        r = sum((cat(2, right_chunks{high})),'all');
        bias(2) = (l-r)/(l+r);
        
        indiscrim = ids == 8;
        l = sum((cat(2, left_chunks{indiscrim})), 'all');
        r = sum((cat(2, right_chunks{indiscrim})), 'all');
        bias(3) = (l-r)/(l+r);        
        
        %ids = ["Low", "High", "Category Boundary"];
    else        
        bias =  (sum(lefts, 'all')- sum(rights, 'all'))/(sum(lefts, 'all')+ sum(rights, 'all'));
        %ids = "overall";
    end
        
    
    
    
    
    
end