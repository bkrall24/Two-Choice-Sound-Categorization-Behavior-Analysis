function [x,y] = get_performance_trajectory(name, stimuli, sig,  content, choice)
    
    % Rebecca Krall
    %
    % Inputs:
    %   name - struct, output of analyze_animal
    %   stimuli - string, indicates what types of trials to analyze,
    %       options: easy, hard, discriminable, all, low, high
    %   choice - boolean array, indicates a trial selection beyond stimulus
    %       type, i.e. name.sessionNum == 11, or contains(name.parameter,
    %       'psych')
    %   sig - number, default is 200, number of trials over which to
    %       calculate the success rate
    %   content - string, indicates what you're calculated. Default is
    %       'hits' - i.e. success rate
    %       'right' - bias rate
    %       'no go' 
    
    if nargin < 3
        sig = 200;
    end
    if nargin < 5
        choice = true(size(name.stimulus));
    end
    if nargin < 4
        content = 'hits';
    end
    
    trial_reference = 1:length(name.stimulus);
    
    if stimuli == "easy"
        choose = name.stimulus == 2 | name.stimulus == 2.828427 | name.stimulus == 22.627417 | name.stimulus == 32;
    elseif stimuli == "discriminable"
        choose = name.stimulus ~= 8;
    elseif stimuli == "hard"
        choose = name.stimulus == 4.0000 | name.stimulus == 5.65685400000000 | name.stimulus == 11.3137080000000 | name.stimulus ==  16.0000;
    elseif stimuli == "low"
        choose = name.stimulus < 8;
    elseif stimuli == "high"
        choose = name.stimulus > 8;
    elseif stimuli == "eight"
        choose = name.stimulus == 8;
    else
        choose = true(size(name.stimulus));
    end
           
    go = name.lick(1,:) | name.lick(2,:)| name.lick(3,:) | name.lick(4,:);
    x = trial_reference(choose & choice & go); 
    
    if content == "hits"
        hits = name.lick(1, choice & choose & go) | name.lick(2, choice & choose & go); 
    elseif content == "right"
        hits = name.lick(1, choice & choose & go) | name.lick(4, choice & choose & go); 
    elseif content == "no go"
        hits = name.lick(5, choice & choose & go) ;
    end
    
    y = movsum(hits, [sig, 0])./sig;

    
end