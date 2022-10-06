function [choice, rxn] = rescore_animal(ttl,response_period)

    choice = zeros(5, size(ttl.choice,1));
    
    if nargin == 1
        response_period = 750:850;
    end
    
    choice = [];
    rxn = [];
% Goal: pull out the first reaction in the lick rasters
    for i = 1:size(ttl.choice,1)
        c = squeeze(ttl.choice(i,:, response_period));
        [ch,rx] = find(c,1,'first');
        
        if ~isempty(ch)
            choice(ch,i) = 1;
        else
            choice(5,i) = 1;
        end
        
        if ~isempty(rx)
            rxn(i) = rx *2 + (response_period(1) - 750);
        else
            rxn(i) =  -1;
        end
        
       
    end



end