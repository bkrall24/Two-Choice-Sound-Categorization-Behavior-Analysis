function [trials, choose] = select_trials(name, varargin)

    % The idea for this function is to have a single function that takes a
    % structure from analyzeAnimal and pulls out the relevant data based on
    % some other condition passed into the varargin. Then returns the data in
    % the same struct format

    % possible inputs to varargin
    % Days - an array of ints to pull out specific days of behavior
    % Trials - a boolean array corresponding to the total number of trials
    % Psych - a flag that selects just the psychometric days
    % Criteria - idk how to do this but maybe something that determines once
    % the animal has passed some criteria

    select = varargin{1};
    
    if islogical(select)

        choose = select;

    elseif isa(select, 'double')

       % choose = ismember(name.sessionNum, select);
       try
        choose = false(1,length(name.sessionNum));
       catch
           choose = false(1, length(name.session));
       end
       choose(select) = true;
       %choose = logical(choose)

    elseif isequal(select, 'operant')

        if length(varargin) > 1
            which_op = varargin{2};
        else
            which_op = "trials";
        end

        op = contains(name.parameter, 'dualspout_op');
        psy = contains(name.parameter, 'psych');
        psy_counts = splitapply(@sum, psy, findgroups(name.sessionNum));

        if which_op == "days"
            last_day_op = find(psy_counts > 100, 1, 'first')-1;
            choose = ismember(name.sessionNum, 1:last_day_op) & op;
        else
            choose = op & ~psy;
        end

    elseif isequal(select, 'psych')

        if length(varargin) > 1
            which_psy = varargin{2};
        else
            which_psy = "trials";
        end

        op = contains(name.parameter, 'dualspout_op');
        psy = contains(name.parameter, 'psych');
        psy_counts = splitapply(@sum, psy, findgroups(name.sessionNum));

        if which_psy == "days"
            first_day_psy = find(psy_counts > 100, 1, 'first');
            choose = ismember(name.sessionNum, first_day_psy:max(name.sessionNum));
        else
            choose = psy;
        end
        
    elseif isequal(select, 'opto')
         if length(varargin) > 1
            which_psy = varargin{2};
        else
            which_psy = "trials";
        end

        opto = contains(name.parameter, 'OPTO');
        
       	opto_counts = splitapply(@sum, opto, findgroups(name.sessionNum));

        if which_psy == "days"
            first_day_psy = find(opto_counts > 20, 1, 'first');
            choose = ismember(name.sessionNum, first_day_psy:max(name.sessionNum));
        else
            choose = opto;
        end
    end



    trials = struct();
    fields = fieldnames(name);
    for i = 1:length(fields)
        past = getfield(name, fields{i});
        trials = setfield(trials, fields{i}, past(:,choose));
        
    end




end