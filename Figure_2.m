% Figure 2
%% Fig 2: Excitatory neurons are required for accurate categorization of AM noise
%   Inhibiting excitatory neurons en masse reduces accurate categorization
%   of AM noise. However, inhibition of individual projection neuron types
%   does not impa

% Fig 2A: Performance (% correct LED  on versus off, CAMKII versus control)
% Fig 2B: Psychometric curve example
% Fig 2C: plots for the change in parameters for each animal's curve
% Fig 2D: Bias (left- right/left+right)
% Fig 2E: No Go Rate
% Fig 2F: Reaction Rate

%% First grab the data
control = get_animal_array;
CAMKII = get_animal_array;

%% Next select just the 2000 trials after animal reached 'expert' level
for i = 1:length(CAMKII)
    tc = analyze_training(CAMKII(i));
    choose = false(1,length(CAMKII(i).stimulus));
    choose(tc.trials_expert: tc.trials_expert +2000) = true;    
    cmk2(i) = select_trials(CAMKII(i), choose);
end
for i = 1:length(control)
    tc = analyze_training(control(i));
    choose = false(1,length(control(i).stimulus));
    choose(tc.trials_expert: tc.trials_expert +2000) = true;    
    ctl(i) = select_trials(control(i), choose);
end
%% Next calculate the percent correct on easy, hard and indiscriminable trials
for i = 1:length(cmk2)
    led = logical(cmk2(i).LED);
    h(i,:,2) = calculate_percentages(cmk2(i).lick(:,led), cmk2(i).stimulus(led), 'easy', 'Hits');
    h(i,:,1) = calculate_percentages(cmk2(i).lick(:,~led), cmk2(i).stimulus(~led), 'easy', 'Hits');
end
for i = 1:length(ctl)
    led = logical(ctl(i).LED);
    b(i,:,2) = calculate_percentages(ctl(i).lick(:,led), ctl(i).stimulus(led), 'easy', 'Hits');
    b(i,:,1) = calculate_percentages(ctl(i).lick(:,~led), ctl(i).stimulus(~led), 'easy', 'Hits');
end

%% Plot performance with and without LED
figure
titles = {'Easy Trials', 'Hard Trials', 'Indiscriminable Trials'};
for i = 1:size(b,2)
    subplot(1,3,i)
    plotDataPointsError(squeeze(h(:,i,:)),3:4, [0 0 0], true, false)
    plotDataPointsError(squeeze(b(:,i,:)), 1:2, [0 0 0], true, false)
    title(titles{i});
    xticks([1.5, 3.5])
    xticklabels(["Control", "CAMKII"])
    ylabel('Percent Correct')
    ylim([0 1])
end



%% Plot example psychometric curves for control and CAMKII
figure

c = 1;
subplot(1,2,1)
led = logical(ctl(c).LED);
highSide = mode(ctl(c).target(ctl(c).stimulus == 2));
[xAxis, yData, errorbars] = generate_psych_data(ctl(c).lick(:,~led), ctl(c).stimulus(~led),highSide);
psych = fit_psychometric_curve(xAxis, yData, false, 'k');
plot_single_psychometric_curve(psych, 'k', errorbars);

[xAxis, yData, errorbars] = generate_psych_data(ctl(c).lick(:,led), ctl(c).stimulus(led),highSide);
psych = fit_psychometric_curve(xAxis, yData, false, 'k');
plot_single_psychometric_curve(psych, 'b', errorbars);
title('Control')
xlabel('Frequency AM')


c = 3;
led = logical(cmk2(c).LED);
highSide = mode(cmk2(c).target(cmk2(c).stimulus == 2));
subplot(1,2,2)
[xAxis, yData, errorbars] = generate_psych_data(cmk2(c).lick(:,~led), cmk2(c).stimulus(~led), highSide);
psych = fit_psychometric_curve(xAxis, yData, false, 'k');
plot_single_psychometric_curve(psych, 'k', errorbars);

[xAxis, yData, errorbars] = generate_psych_data(cmk2(c).lick(:,led), cmk2(c).stimulus(led), highSide);
psych = fit_psychometric_curve(xAxis, yData, false, 'k');
plot_single_psychometric_curve(psych, 'b', errorbars);
title('CAMKII')
xlabel('Frequency AM')

%% Population psych fits

for i = 1:length(cmk2)
    led = logical(cmk2(i).LED);
    highSide = mode(cmk2(i).target(cmk2(i).stimulus == 2));
    [xAxis, yData, ~] = generate_psych_data(cmk2(i).lick(:,~led), cmk2(i).stimulus(~led), highSide);
    psych = fit_psychometric_curve(xAxis, yData, false, 'k');
    ll(i,1) = psych.fit.low_lapse;
    hl(i,1) = psych.fit.high_lapse;
    bi(i,1) = psych.fit.bias;
    thr(i,1) = psych.fit.threshold;
    
    [xAxis, yData, ~] = generate_psych_data(cmk2(i).lick(:,led), cmk2(i).stimulus(led), highSide);
    psych = fit_psychometric_curve(xAxis, yData, false, 'k');
    ll(i,2) = psych.fit.low_lapse;
    hl(i,2) = psych.fit.high_lapse;
    bi(i,2) = psych.fit.bias;
    thr(i,2) = psych.fit.threshold;
end

for i = 1:length(ctl)
    led = logical(ctl(i).LED);
    highSide = mode(ctl(i).target(ctl(i).stimulus == 2));
    [xAxis, yData, ~] = generate_psych_data(ctl(i).lick(:,~led), ctl(i).stimulus(~led), highSide);
    psych = fit_psychometric_curve(xAxis, yData, false, 'k');
    ll2(i,1) = psych.fit.low_lapse;
    hl2(i,1) = psych.fit.high_lapse;
    b2(i,1) = psych.fit.bias;
    thr2(i,1) = psych.fit.threshold;
    
    [xAxis, yData, ~] = generate_psych_data(ctl(i).lick(:,led), ctl(i).stimulus(led), highSide);
    psych = fit_psychometric_curve(xAxis, yData, false, 'k');
    ll2(i,2) = psych.fit.low_lapse;
    hl2(i,2) = psych.fit.high_lapse;
    b2(i,2) = psych.fit.bias;
    thr2(i,2) = psych.fit.threshold;
end
%% Plot parameters of psychometric curves
figure
subplot(1,4,1)
plotDataPointsError(abs(bi-8), 3:4, [0 0 0], true, true)
hold on
plotDataPointsError(abs(b2-8), 1:2, [0 0 0], true, true)
xticks([1.5, 3.5])
xticklabels({'Control', 'CAMKII'})
ylabel('Difference from 8 Hz')
title('Bias')
axis square

subplot(1,4,2)
plotDataPointsError(thr, 3:4, [0 0 0], true, true)
hold on
plotDataPointsError(thr2, 1:2, [0 0 0], true, true)
xticks([1.5, 3.5])
xticklabels({'Control', 'CAMKII'})
title('Threshold')
axis square

subplot(1,4,3)
plotDataPointsError(hl, 3:4, [0 0 0], true, true)
hold on
plotDataPointsError(hl2, 1:2, [0 0 0], true, true)
xticks([1.5, 3.5])
xticklabels({'Control', 'CAMKII'})
title('High Lapse')
axis square

subplot(1,4,4)
plotDataPointsError(ll, 3:4, [0 0 0], true, true)
hold on
plotDataPointsError(ll2, 1:2, [0 0 0], true, true)
xticks([1.5, 3.5])
xticklabels({'Control', 'CAMKII'})
title('Low Lapse')
axis square


%% Plot bias
figure
for i = 1:length(cmk2)
    led = logical(cmk2(i).LED);
    if mode(cmk2(i).target(cmk2(i).stimulus == 32)) == 1
        bias(i,1) = (sum(cmk2(i).lick([2,3],~led), 'all') - sum(cmk2(i).lick([1,4],~led), 'all')) / sum(cmk2(i).lick([1:4],~led), 'all');
        bias(i,2) = (sum(cmk2(i).lick([2,3],led), 'all') - sum(cmk2(i).lick([1,4],led), 'all')) / sum(cmk2(i).lick([1:4],led), 'all');
    else
        bias(i,1) = (sum(cmk2(i).lick([1,4],~led), 'all') - sum(cmk2(i).lick([2,3],~led), 'all')) / sum(cmk2(i).lick([1:4],~led), 'all');
        bias(i,2) = (sum(cmk2(i).lick([1,4],led), 'all') - sum(cmk2(i).lick([2,3],led), 'all')) / sum(cmk2(i).lick([1:4],led), 'all');
    end
end

for i = 1:length(ctl)
    led = logical(ctl(i).LED);
    if mode(ctl(i).target(ctl(i).stimulus == 32)) == 1
        bias2(i,1) = (sum(ctl(i).lick([2,3],~led), 'all') - sum(ctl(i).lick([1,4],~led), 'all')) / sum(ctl(i).lick([1:4],~led), 'all');
        bias2(i,2) = (sum(ctl(i).lick([2,3],led), 'all') - sum(ctl(i).lick([1,4],led), 'all')) / sum(ctl(i).lick([1:4],led), 'all');
    else
        bias2(i,1) = (sum(ctl(i).lick([1,4],~led), 'all') - sum(ctl(i).lick([2,3],~led), 'all')) / sum(ctl(i).lick([1:4],~led), 'all');
        bias2(i,2) = (sum(ctl(i).lick([1,4],led), 'all') - sum(ctl(i).lick([2,3],led), 'all')) / sum(ctl(i).lick([1:4],led), 'all');
    end
end
plotDataPointsError((bias), 3:4, [0 0 0], true, true)
plotDataPointsError((bias2), 1:2, [0 0 0], true, true)
xticks([1.5, 3.5])
xticklabels({'Control', 'CAMKII'})
title('Bias')

%% plot no go rate
figure
for i = 1:length(cmk2)
    led = logical(cmk2(i).LED);
    ng(i,2) = calculate_percentages(cmk2(i).lick(:,led), cmk2(i).stimulus(led), 'd', 'No Go');
    ng(i,1) = calculate_percentages(cmk2(i).lick(:,~led), cmk2(i).stimulus(~led), 'f', 'No Go');
end
for i = 1:length(ctl)
    led = logical(ctl(i).LED);
    ng2(i,2) = calculate_percentages(ctl(i).lick(:,led), ctl(i).stimulus(led), 'd', 'No Go');
    ng2(i,1) = calculate_percentages(ctl(i).lick(:,~led), ctl(i).stimulus(~led), 'f', 'No Go');
end
plotDataPointsError(ng, 3:4, [0 0 0], true, true)
plotDataPointsError(ng2, 1:2, [0 0 0], true, true)
xticks([1.5, 3.5])
xticklabels({'Control', 'CAMKII'})
title('No Go Rate')

%% plot reaction times
figure
for i = 1:length(cmk2)
    led = logical(cmk2(i).LED);
    rchoice = cmk2(i).rxnTime > 0;
    r(i,2) = calculate_means(cmk2(i).rxnTime(led & rchoice), cmk2(i).stimulus(led & rchoice), 'd');
    r(i,1) = calculate_means(cmk2(i).rxnTime(~led & rchoice), cmk2(i).stimulus(~led & rchoice), 'f');
end
for i = 1:length(ctl)
    led = logical(ctl(i).LED);
    rchoice = ctl(i).rxnTime > 0;
    r2(i,2) = calculate_means(ctl(i).rxnTime(led& rchoice), ctl(i).stimulus(led& rchoice), 'd');
    r2(i,1) = calculate_means(ctl(i).rxnTime(~led& rchoice), ctl(i).stimulus(~led& rchoice), 'f');
end
plotDataPointsError(r-500, 3:4, [0 0 0], true, true)
plotDataPointsError(r2-500, 1:2, [0 0 0], true, true)
xticks([1.5, 3.5])
xticklabels({'Control', 'CAMKII'})
title('Reaction Time')