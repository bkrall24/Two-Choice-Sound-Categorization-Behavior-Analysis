% figure 4 - looking at difference in training/learning


% hypothesis: intermittent inhibition of ET/IT neurons causes a disruption
% in learning leading to increase in the amount of trials necessary to
% learn the task


% Panel A. Training progression - threshold for optogenetics (60% correct
% over 200 'easy' trials). - threshold for proficient (85% correct over 
% 200 easy trials). - threshold for expert

% Panel B. Total number of trials needed to reach proficient and expert
%   - types of trials: easy, high, low, hard, opto
num_groups = 5


for j = 1:num_groups
    [animal_array, animal_id] = get_animal_array();
    opto_thresh= [];
    prof_thresh = [];
    exp_thresh = [];

    for i = 1:length(animal_array)
        animal = animal_array(i);
        train = analyze_training(animal);

        select_opto = zeros(1,length(animal.target));
        select_opto(1:train.trials_opto) = 1;
        opto = select_trials(animal, logical(select_opto));

        o.total = length(opto.stimulus);
        o.op = sum(~contains(opto.parameter, 'pav'));
        o.pav = sum(contains(opto.parameter, 'pav'));
        o.low = sum(opto.stimulus < 8);
        o.high = sum(opto.stimulus > 8);


        select_prof = zeros(1,length(animal.target));
        select_prof(train.trials_opto:train.trials_proficient) = 1;
        prof = select_trials(animal, logical(select_prof));

        p.total = sum(~prof.LED);
        p.low = sum(prof.stimulus < 8 & ~prof.LED);
        p.high = sum(prof.stimulus > 8 & ~prof.LED);
        p.opto_t = sum(prof.LED & ~prof.LED);
        p.corrections = sum(contains(prof.parameter, '_low') | contains(prof.parameter, '_high'));
        p.psych = sum(contains(prof.parameter, 'psych'));


        select_exp = zeros(1,length(animal.target));
        select_exp(train.trials_proficient:train.trials_expert) = 1;
        exp = select_trials(animal, logical(select_exp));

        e.total = length(exp.stimulus);
        e.easy = sum((exp.stimulus < 3 | exp.stimulus > 20 )& ~exp.LED);
        e.hard = sum(exp.stimulus > 3 & exp.stimulus < 20 & ~exp.LED);
        e.low = sum(exp.stimulus < 8 & ~exp.LED);
        e.high = sum(exp.stimulus > 8 & ~exp.LED);
        e.opto = sum(exp.LED);
        e.psych = sum(contains(exp.parameter, 'psych'));
        e.corrections = sum(contains(exp.parameter, '_low') | contains(exp.parameter, '_high'));

        opto_thresh = [opto_thresh, o];
        prof_thresh = [prof_thresh, p];
        exp_thresh = [exp_thresh, e];
    end
    oo{j} = opto_thresh;
    pp{j} = prof_thresh;
    ee{j} = exp_thresh;
end


m = cellfun(@(x) nanmean([x.total]), oo);
s = cellfun(@(x) sem([x.total]'), oo);
a = cellfun(@(x) [x.total], oo, 'UniformOutput', false);
for i = 1:length(a)
    hold on
    scatter(ones(1, length(a{i}))*i, a{i})
end
errorbar(m,s, 'ok');

m = cellfun(@(x) nanmean([x.total]-[x.psych]), pp);
s = cellfun(@(x) sem(([x.total]-[x.psych])'), pp);
a = cellfun(@(x) [x.total]-[x.psych], pp, 'UniformOutput', false);
for i = 1:length(a)
    hold on
    scatter(ones(1, length(a{i}))*i, a{i})
end

errorbar(m,s, 'ok');


m = cellfun(@(x) nanmean([x.total]), ee);
s = cellfun(@(x) sem([x.total]'), ee);
a = cellfun(@(x) [x.total], ee, 'UniformOutput', false);
for i = 1:length(a)
    hold on
    scatter(ones(1, length(a{i}))*i, a{i})
end

errorbar(m,s, 'ok');

