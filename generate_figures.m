% Code to generate figures

%% Fig. 1: 
%   Mice learn to categorize amplitude modulated noise 

% Fig 1A: Schematic of behavioral setup 
% Fig 1B: Schematic of behavioral trial
% Fig 1C: Example trace of performance on easy and hard trials 
% Fig 1D: Example psychometric curves early, mid, and late
% Fig 1E: Example of reduction of reaction times over the course of
% learning

% Fig 1F: Group averages of controls (124,125, 129) success rate from trial
%   1 to 'expert' threshold, averaged

%%
example_mouse = analyze_animal('W:\Data\2AFC_Behavior\c_124');
sig = 500;


figure
subplot(3,3,1:3)
[x,y] = get_performance_trajectory(example_mouse, 'easy', sig);
plot(x(sig:end),y(sig:end),'b')
hold on
start = x(sig);

[x,y] = get_performance_trajectory(example_mouse, 'hard', sig);
plot(x(sig:end),y(sig:end),'r')
hold on

plot(diff(example_mouse.sessionNum), ':', 'color', [0.5 0.5 0.5])
xlim([start length(example_mouse.sessionNum)])
ylim([0.5 1])

ylabel('Success Rate')
xlabel('Trials')
text(length(example_mouse.sessionNum)-200, 0.625, 'Easy', 'color', 'b', 'HorizontalAlignment', 'right')
text(length(example_mouse.sessionNum)-200, 0.55, 'Hard', 'color', 'r', 'HorizontalAlignment', 'right')

subplot(3,3,4)
[xAxis, yData, errorbars] = generate_psych_data( ...
    example_mouse.lick(:,example_mouse.sessionNum == 12), ...
    example_mouse.stimulus(example_mouse.sessionNum == 12));
psych = fit_psychometric_curve(xAxis, yData, false);
plot_single_psychometric_curve(psych, 'k', errorbars)
ylabel('Proportion Lick Right')
xlabel('Frequency (Hz)')
title('Early ')

subplot(3,3,5)
[xAxis, yData, errorbars] = generate_psych_data( ...
    example_mouse.lick(:,example_mouse.sessionNum == 17), ...
    example_mouse.stimulus(example_mouse.sessionNum == 17));
psych = fit_psychometric_curve(xAxis, yData, false);
plot_single_psychometric_curve(psych, 'k', errorbars)
ylabel('Proportion Lick Right')
xlabel('Frequency (Hz)')
title('Mid ')

subplot(3,3,6)
[xAxis, yData, errorbars] = generate_psych_data( ...
    example_mouse.lick(:,example_mouse.sessionNum == 22), ...
    example_mouse.stimulus(example_mouse.sessionNum == 22));
psych = fit_psychometric_curve(xAxis, yData, false);
plot_single_psychometric_curve(psych, 'k', errorbars)
ylabel('Proportion Lick Right')
xlabel('Frequency (Hz)')
title('Late ')

subplot(3,3,7:9)
trial_reference = 1:length(example_mouse.stimulus);
go = example_mouse.rxnTime > 500;
easy = example_mouse.stimulus == 2 | example_mouse.stimulus == 2.828427 | example_mouse.stimulus == 22.627417 | example_mouse.stimulus == 32;
hard = example_mouse.stimulus == 4.0000 | example_mouse.stimulus == 5.65685400000000 | example_mouse.stimulus == 11.3137080000000 | example_mouse.stimulus ==  16.0000;

easy_rxn = movsum(example_mouse.rxnTime(easy & go), [sig, 0])./sig;
easy_trials = trial_reference(easy &go);
hard_rxn = movsum(example_mouse.rxnTime(hard & go), [sig, 0])./sig;
hard_trials = trial_reference(hard&go);

plot(easy_trials(sig:end), easy_rxn(sig:end)-500, 'b');
hold on
plot(hard_trials(sig:end),hard_rxn(sig:end)-500, 'r');
xlim([0 length(example_mouse.sessionNum)])
ylabel('Reaction Time (ms)')
xlabel('Trials')
text(length(example_mouse.sessionNum)-200, 400, 'Easy', 'color', 'b', 'HorizontalAlignment', 'right')
text(length(example_mouse.sessionNum)-200, 360, 'Hard', 'color', 'r', 'HorizontalAlignment', 'right')
plot(diff(example_mouse.sessionNum)*1000, ':', 'color', [0.5 0.5 0.5])
ylim([200 450])
xlim([start length(example_mouse.sessionNum)])

%%
control = get_animal_array;
%subplot(4,3,10:12)
figure
hold on
for i = 1:length(control)
    t(i) = analyze_training(control(i));
    
    choose_training_period = false(length(control(i).stimulus),1);
    choose_training_period(1:t(i).trials_expert) = true;
    animal = select_trials(control(i), choose_training_period);
    
    [d_x, d_y] = get_performance_trajectory(animal, "easy", sig);
    %x = d_x(sig:end) ./ d_x(end);
    %norm_y(i,:) = interp1(x, d_y(sig:end), 0:0.005:1);
    plot(sig:length(d_y), d_y(sig:end), 'color', [0 0 0 0.5])
    hold on
    %norm_y(i,:) = d_y(sig:2500);
        
end

%shadedErrorBar(sig:2500, nanmean(norm_y), sem(norm_y), 'b', 1)
yline(0.85, ':')
xlabel('Trials')
ylabel('Success Rate')
%xlim([sig,5000])
ylim([0.5, 1])
text(550, 0.9, 'Easy', 'color', 'b', 'HorizontalAlignment', 'left')
set(gcf,'renderer','painter','color',[1 1 1]);


figure
subplot(1,2,1)
errorbar(1, nanmean([t.trials_proficient]), sem([t.trials_proficient]'),'_k')
hold on
scatter(ones(1, length([t.trials_proficient])), [t.trials_proficient],'k')
errorbar(2, nanmean([t.trials_expert]), sem([t.trials_expert]'),'_k')
scatter(ones(1, length([t.trials_expert]))*2, [t.trials_expert],'k')
xticks([1,2])
xticklabels({'Proficient', 'Expert'})
xlim([0.75 2.25])
title('Trials till Threshold')


subplot(1,2,2)
errorbar(1, nanmean([t.days_proficient]), sem([t.days_proficient]'),'_k')
hold on
scatter(ones(1, length([t.days_proficient])), [t.days_proficient],'k')
errorbar(2, nanmean([t.days_expert]), sem([t.days_expert]'),'_k')
scatter(ones(1, length([t.days_expert]))*2, [t.days_expert],'k')
axis padded
xticks([1,2])
xticklabels({'Proficient', 'Expert'})
xlim([0.75 2.25])
title('Sessions till Threshold')


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

CAMKII = get_animal_array;
control = get_animal_array;

for i = 1:length(CAMKII)
    tc = analyze_training(CAMKII(i));
    choose = false(1,length(CAMKII(i).stimulus));
    choose(tc.trials_expert: tc.trials_expert +1000) = true;    
    cmk2(i) = select_trials(CAMKII(i), choose);
end
for i = 1:length(control)
    tc = analyze_training(control(i));
    choose = false(1,length(control(i).stimulus));
    choose(tc.trials_expert: tc.trials_expert +1000) = true;    
    ctl(i) = select_trials(control(i), choose);
end
%%
for i = 1:length(cmk2)
    led = logical(cmk2(i).LED);
    h(i,:,2) = calculate_percentages(cmk2(i).lick(:,led), cmk2(i).stimulus(led), 'low', 'Hits');
    h(i,:,1) = calculate_percentages(cmk2(i).lick(:,~led), cmk2(i).stimulus(~led), 'low', 'Hits');
end
for i = 1:length(ctl)
    led = logical(ctl(i).LED);
    b(i,:,2) = calculate_percentages(ctl(i).lick(:,led), ctl(i).stimulus(led), 'low', 'Hits');
    b(i,:,1) = calculate_percentages(ctl(i).lick(:,~led), ctl(i).stimulus(~led), 'low', 'Hits');
end

%% Performance with and without LED
subplot(1,3,1)
plotDataPointsError(squeeze(h(:,1,:)),3:4, [0 0 0], true, false)
plotDataPointsError(squeeze(b(:,1,:)), 1:2, [0 0 0], true, false)
title('Low Trials')
ylabel('Percent Correct')
ylim([0 1])
subplot(1,3,2)
plotDataPointsError(squeeze(h(:,2,:)), 3:4, [0 0 0], true, false)
plotDataPointsError(squeeze(b(:,2,:)),1:2, [0 0 0], true, false)
title('High Trials')
ylabel('Percent Correct')
ylim([0 1])
subplot(1,3,3)
plotDataPointsError(squeeze(h(:,3,:)), 3:4, [0 0 0], true, false)
plotDataPointsError(squeeze(b(:,3,:)), 1:2, [0 0 0], true, false)
title('Indiscriminable Trials')
ylabel('Percent Correct')
ylim([0 1])

%% Example psychometric curve
c = 2
led = logical(cmk2(c).LED);
subplot(1,2,2)
[xAxis, yData, errorbars] = generate_psych_data(cmk2(c).lick(:,~led), cmk2(c).stimulus(~led), 0);
psych = fit_psychometric_curve(xAxis, yData, false, 'k');
plot_single_psychometric_curve(psych, 'k', errorbars);

[xAxis, yData, errorbars] = generate_psych_data(cmk2(c).lick(:,led), cmk2(c).stimulus(led), 0);
psych = fit_psychometric_curve(xAxis, yData, false, 'k');
plot_single_psychometric_curve(psych, 'b', errorbars);

c = 3
subplot(1,2,1)
led = logical(ctl(c).LED);
[xAxis, yData, errorbars] = generate_psych_data(ctl(c).lick(:,~led), ctl(c).stimulus(~led),0);
psych = fit_psychometric_curve(xAxis, yData, false, 'k');
plot_single_psychometric_curve(psych, 'k', errorbars);

[xAxis, yData, errorbars] = generate_psych_data(ctl(c).lick(:,led), ctl(c).stimulus(led),0);
psych = fit_psychometric_curve(xAxis, yData, false, 'k');
plot_single_psychometric_curve(psych, 'b', errorbars);


%% Population psych fits

for i = 1:length(cmk2)
    led = logical(cmk2(i).LED);
    highSide = mode(cmk2(i).target(cmk2(i).stimulus == 2));
    [xAxis, yData, errorbars] = generate_psych_data(cmk2(i).lick(:,~led), cmk2(i).stimulus(~led), highSide);
    psych = fit_psychometric_curve(xAxis, yData, false, 'k');
    ll(i,1) = psych.fit.low_lapse;
    hl(i,1) = psych.fit.high_lapse;
    bi(i,1) = psych.fit.bias;
    thr(i,1) = psych.fit.threshold;
    
    [xAxis, yData, errorbars] = generate_psych_data(cmk2(i).lick(:,led), cmk2(i).stimulus(led), highSide);
    psych = fit_psychometric_curve(xAxis, yData, false, 'k');
    ll(i,2) = psych.fit.low_lapse;
    hl(i,2) = psych.fit.high_lapse;
    bi(i,2) = psych.fit.bias;
    thr(i,2) = psych.fit.threshold;
end

for i = 1:length(ctl)
    led = logical(ctl(i).LED);
    highSide = mode(ctl(i).target(ctl(i).stimulus == 2));
    [xAxis, yData, errorbars] = generate_psych_data(ctl(i).lick(:,~led), ctl(i).stimulus(~led), highSide);
    psych = fit_psychometric_curve(xAxis, yData, false, 'k');
    ll2(i,1) = psych.fit.low_lapse;
    hl2(i,1) = psych.fit.high_lapse;
    b2(i,1) = psych.fit.bias;
    thr2(i,1) = psych.fit.threshold;
    
    [xAxis, yData, errorbars] = generate_psych_data(ctl(i).lick(:,led), ctl(i).stimulus(led), highSide);
    psych = fit_psychometric_curve(xAxis, yData, false, 'k');
    ll2(i,2) = psych.fit.low_lapse;
    hl2(i,2) = psych.fit.high_lapse;
    b2(i,2) = psych.fit.bias;
    thr2(i,2) = psych.fit.threshold;
end
%% Plot parameters of psychometric curves
subplot(1,4,1)
plotDataPointsError(abs(bi-8), 3:4, [0 0 0], true, false)
hold on
plotDataPointsError(abs(b2-8), 1:2, [0 0 0], true, false)
xticks([1.5, 3.5])
xticklabels({'Control', 'CAMKII'})
ylabel('Difference from 8 Hz')
title('Bias')
axis square

subplot(1,4,2)
plotDataPointsError(thr, 3:4, [0 0 0], true, false)
hold on
plotDataPointsError(thr2, 1:2, [0 0 0], true, false)
xticks([1.5, 3.5])
xticklabels({'Control', 'CAMKII'})
title('Threshold')
axis square

subplot(1,4,3)
plotDataPointsError(hl, 3:4, [0 0 0], true, false)
hold on
plotDataPointsError(hl2, 1:2, [0 0 0], true, false)
xticks([1.5, 3.5])
xticklabels({'Control', 'CAMKII'})
title('High Lapse')
axis square

subplot(1,4,4)
plotDataPointsError(ll, 3:4, [0 0 0], true, false)
hold on
plotDataPointsError(ll2, 1:2, [0 0 0], true, false)
xticks([1.5, 3.5])
xticklabels({'Control', 'CAMKII'})
title('Low Lapse')
axis square


%% Plot bias
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
    if mode(ctl(i).target(cmk2(i).stimulus == 32)) == 1
        bias2(i,1) = (sum(ctl(i).lick([2,3],~led), 'all') - sum(ctl(i).lick([1,4],~led), 'all')) / sum(ctl(i).lick([1:4],~led), 'all');
        bias2(i,2) = (sum(ctl(i).lick([2,3],led), 'all') - sum(ctl(i).lick([1,4],led), 'all')) / sum(ctl(i).lick([1:4],led), 'all');
    else
        bias2(i,1) = (sum(ctl(i).lick([1,4],~led), 'all') - sum(ctl(i).lick([2,3],~led), 'all')) / sum(ctl(i).lick([1:4],~led), 'all');
        bias2(i,2) = (sum(ctl(i).lick([1,4],led), 'all') - sum(ctl(i).lick([2,3],led), 'all')) / sum(ctl(i).lick([1:4],led), 'all');
    end
end
plotDataPointsError((bias), 3:4, [0 0 0], true, false)
plotDataPointsError((bias2), 1:2, [0 0 0], true, false)
xticks([1.5, 3.5])
xticklabels({'Control', 'CAMKII'})

%% plot no go rate
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
plotDataPointsError(ng, 3:4, [0 0 0], true, false)
plotDataPointsError(ng2, 1:2, [0 0 0], true, false)
xticks([1.5, 3.5])
xticklabels({'Control', 'CAMKII'})

%% plot reaction times

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
plotDataPointsError(r-500, 3:4, [0 0 0], true, false)
plotDataPointsError(r2-500, 1:2, [0 0 0], true, false)
xticks([1.5, 3.5])
xticklabels({'Control', 'CAMKII'})
%% Fig 3: The effect of LED changes over the course of training

% population effect on bias with LED on versus off - either some continuous plot (movsum) or binned
% bin the data relative to proficient to determine 'stages' of learning based on LED effect and plot the effect of LED at each stage
%
%


%% Fig 4: Differences in training across cell types
% plot effect of LED - same as fig 2 - for each cell type to show no effect
% at expert level
% plot all the opto -> expert trajectories on non-normalized axes
% sessions and trials to reach thresholds
num_groups = 2;
for i = 1:num_groups
    group = get_animal_array;
    
    names(i) = inputdlg('Group Name')
    for j = 1:length(group)
        tc = analyze_training(group(j));
        choose = false(1,length(group(j).stimulus));
        choose(tc.trials_expert: length(group(j).stimulus)) = true;    
        animal(j) = select_trials(group(j), choose);
        choose2 = false(1,length(group(j).stimulus));
        choose2(tc.trials_opto: length(group(j).stimulus)) = true; 
        animal2(j) = select_trials(group(j), choose2);
        
        choose3 = false(1,length(group(j).stimulus));
        choose3(tc.trials_opto: tc.trials_proficient) = true; 
        animal3(j) = select_trials(group(j), choose3);
        train(j) = tc;
        first_psy(j,:) = find(group(j).stimulus == 8, 10, 'first')
    end
    groups{i} = animal;
    traj{i} = animal2;
    training{i} = train;
    toprof{i} = animal3;
    fp{i} = first_psy;
    clear animal3
    clear animal
    clear animal2
    clear train
    clear first_psy
   
end


%% plot performance of each group at expert level
for i = 1:length(groups)
    g = groups{i};
    for j = 1:length(g)
        led = logical(g(j).LED);
        p(j,2) = calculate_percentages(g(j).lick(:,led), g(j).stimulus(led), 'a', 'Hits');
        p(j,1) = calculate_percentages(g(j).lick(:,~led), g(j).stimulus(~led), 'a', 'Hits');
    end
    perf{i} = p;
    clear p
end

for i = 1:length(perf)
    subplot(1, length(perf), i)
    plotDataPointsError(perf{i} ,1:2, [0 0 0], true, true)
    ylabel('Percent Correct')
    title(names{i})
    xlim([0.75 2.25])
    ylim([0.45 1])
end

%%
for i = 1:length(groups)
    g = groups{i};
    for j = 1:length(g)
        led = logical(g(j).LED);
        r = g(j).rxnTime > 0;
        p(j,2) = calculate_means(g(j).rxnTime(led & r), g(j).stimulus(led & r), 'r');
        p(j,1) = calculate_means(g(j).rxnTime(~led & r), g(j).stimulus(~led & r), 'r');
    end
    rs{i} = p;
    clear p
end

for i = 1:length(rs)
    subplot(1, length(rs), i)
    plotDataPointsError(rs{i}-500 ,1:2, [0 0 0], true, true)
    ylabel('Reaction Time')
    title(names{i})
    xlim([0.75 2.25])
    ylim([250 400])
end


%%
colors = colororder;
colors(:,4) = [0.2 0.2 0.2 0.2 0.2 0.2 0.2];
figure
for i = 1:length(training)
    t = training{i};
    all_t = [];
    for j = 1:length(t)
        hold on
        av = nan(1,max(cellfun(@length, {t.discrim_trajectory})));
        av(1:length(t(j).discrim_trajectory)) = t(j).discrim_trajectory;
        all_t = cat(1, all_t, av);
    end
    all{i} = nanmean(all_t(:,200:end), 1);
end


for i = 1:length(all)
    plot(all{i}, 'color', colors(i, 1:3))
    hold on
end
legend(names, 'Location', 'southeast')
xlim([200 7000])
ylim([0.4 1.01])
    
%%
figure
subplot(1,4,1)
for i = 1:length(training)
    scatter(i * ones(1, length(training{i})), [training{i}.trials_proficient], 'MarkerEdgeColor', colors(i,1:3), 'MarkerEdgeAlpha', 0.2)
    hold on
    if length(training{i}) > 1
        errorbar(i, nanmean([training{i}.trials_proficient]), sem([training{i}.trials_proficient]'), 'Marker', 'o', 'color', colors(i,1:3))
    end
    
end
title('Trials Proficient')
xticks([1:5])
xticklabels(names)
xtickangle(45)
axis square
axis padded

subplot(1,4,2)
for i = 1:length(training)
    scatter(i * ones(1, length(training{i})), [training{i}.days_proficient], 'MarkerEdgeColor', colors(i,1:3), 'MarkerEdgeAlpha', 0.2)
    hold on
    if length(training{i}) > 1
        errorbar(i, nanmean([training{i}.days_proficient]), sem([training{i}.days_proficient]'), 'Marker', 'o', 'color', colors(i,1:3))
    end
    hold on
end
title('Sessions Proficient')
xticks([1:5])
xticklabels(names)
xtickangle(45)
axis square
axis padded

subplot(1,4,3)
for i = 1:length(training)
    scatter(i * ones(1, length(training{i})), [training{i}.trials_expert], 'MarkerEdgeColor', colors(i,1:3), 'MarkerEdgeAlpha', 0.2)
    hold on
    if length(training{i}) > 1
        errorbar(i, nanmean([training{i}.trials_expert]), sem([training{i}.trials_expert]'), 'Marker', 'o', 'color', colors(i,1:3))
    end
    hold on
end
title('Trials Expert')
xticks([1:5])
xticklabels(names)
xtickangle(45)
axis square
axis padded

subplot(1,4,4)
for i = 1:length(training)
    scatter(i * ones(1, length(training{i})), [training{i}.days_expert], 'MarkerEdgeColor', colors(i,1:3), 'MarkerEdgeAlpha', 0.2)
    hold on
    if length(training{i}) > 1
        errorbar(i, nanmean([training{i}.days_expert]), sem([training{i}.days_expert]'), 'Marker', 'o', 'color', colors(i,1:3))
    end
    hold on
end
title('Sessions Expert')
xticks([1:5])
xticklabels(names)
xtickangle(45)
axis square
axis padded


%% 
% consider looking at the number of hard trials exist in the range  
figure
subplot(1,4,1)
for i = 1:length(training)
    scatter(i * ones(1, length(training{i})), [training{i}.trials_expert] - median(fp{1,i}'), 'MarkerEdgeColor', colors(i,1:3), 'MarkerEdgeAlpha', 0.2)
    hold on
    if length(training{i}) > 1
        errorbar(i, nanmean([training{i}.trials_expert] - median(fp{1,i}')), sem(([training{i}.trials_expert] - median(fp{1,i}'))'), 'Marker', 'o', 'color', colors(i,1:3))
    end
    hold on
end
title('Expert - first psych')
xticks([1:5])
xticklabels(names)
xtickangle(45)
axis square
axis padded


subplot(1,4,2)
for i = 1:length(training)
    scatter(i * ones(1, length(training{i})),  median(fp{1,i}'), 'MarkerEdgeColor', colors(i,1:3), 'MarkerEdgeAlpha', 0.2)
    hold on
    if length(training{i}) > 1
        errorbar(i, nanmean(median(fp{1,i}')), sem(( median(fp{1,i}'))'), 'Marker', 'o', 'color', colors(i,1:3))
    end
    hold on
end
title('Trials till first Psych')
xticks([1:5])
xticklabels(names)
xtickangle(45)
axis square
axis padded


subplot(1,4,3)
for i = 1:length(training)
   scatter(i * ones(1, length(training{i})), median(fp{1,i}')- [training{i}.trials_proficient], 'MarkerEdgeColor', colors(i,1:3), 'MarkerEdgeAlpha', 0.2)
    hold on
    if length(training{i}) > 1
        errorbar(i, nanmean( median(fp{1,i}')- [training{i}.trials_proficient]), sem(( median(fp{1,i}')- [training{i}.trials_proficient])'), 'Marker', 'o', 'color', colors(i,1:3))
    end
    hold on
end
title('First Psych - Proficient')
xticks([1:5])
xticklabels(names)
xtickangle(45)
axis square
axis padded


subplot(1,4,4)
for i = 1:length(training)
   scatter(i * ones(1, length(training{i})), [training{i}.trials_expert]- [training{i}.trials_proficient], 'MarkerEdgeColor', colors(i,1:3), 'MarkerEdgeAlpha', 0.2)
    hold on
    if length(training{i}) > 1
        errorbar(i, nanmean( [training{i}.trials_expert]- [training{i}.trials_proficient]), sem(([training{i}.trials_expert]- [training{i}.trials_proficient])'), 'Marker', 'o', 'color', colors(i,1:3))
    end
    hold on
end
title('Expert - Proficient')
xticks([1:5])
xticklabels(names)
xtickangle(45)
axis square
axis padded





%% Max performance

num_groups = 2;
for i = 1:num_groups
    group = get_animal_array;
    
    names(i) = inputdlg('Group Name');
    for j = 1:length(group)
        tc = analyze_training(group(j));
        choose = false(1,length(group(j).stimulus));
        choose(tc.trials_proficient: length(group(j).stimulus)) = true;    
        animal(j) = select_trials(group(j), choose);
        
        
        choose2 = false(1,length(group(j).stimulus));
        choose2(tc.trials_expert: length(group(j).stimulus)) = true; 
        animal2(j) = select_trials(group(j), choose2);
        

    end
    proficient{i} = animal;
    expert{i} = animal2;
    clear animal
    clear animal2
    
end

%%

for i = 1:length(proficient)
    pa = proficient{i}
    for j = 1:length(pa)
        choose_trials = pa(j).stimulus < 4 | pa(j).stimulus > 16;
        led = pa(j).LED
        a = select_trials(pa(j),  choose_trials & ~led)
        ses = unique(a.sessionNum);
        from = ses;
        to = 1:length(ses);
        bins = changem(a.sessionNum, to, from);
        %perf{i,j} = splitapply(@(x) sum(x([1,2],:), 'all')./sum(x(1:4,:), 'all'), a.lick, a.sessionNum - min(a.sessionNum)+1)
        perf{i,j} = splitapply(@(x) sum(x([1,2],:), 'all')./sum(x(1:4,:), 'all'), a.lick,bins)
    end
end

p1 = cellfun(@nanmean, perf)
v1 = cellfun(@var, perf)

%%
for i = 1:length(expert)
    pa = expert{i}
    for j = 1:length(pa)
        choose_trials = pa(j).stimulus >= 4 & pa(j).stimulus <= 16 & pa(j).stimulus ~= 8;
        led = pa(j).LED
        a = select_trials(pa(j),  ~choose_trials & ~led)
        ses = unique(a.sessionNum);
           from = ses;
        to = 1:length(ses);
        bins = changem(a.sessionNum, to, from);
        %perf{i,j} = splitapply(@(x) sum(x([1,2],:), 'all')./sum(x(1:4,:), 'all'), a.lick, a.sessionNum - min(a.sessionNum)+1)
        perf{i,j} = splitapply(@(x) sum(x([1,2],:), 'all')./sum(x(1:4,:), 'all'), a.lick, bins)
    end
end

p2 = cellfun(@nanmean, perf);
v2 = cellfun(@var, perf);


%%
figure
subplot(2,2,1)
errorbar(nanmean(p1,2), sem(p1'), 'ok')
hold on
for i = 1:size(p1,1)
    scatter(ones(1,size(p1,2))*i, p1(i,:))
end
xticks(1:length(proficient))
xticklabels(names)
axis padded
ylim([0.8 1])

subplot(2,2,2)
errorbar(nanmean(v1,2), sem(v1'), 'ok')
hold on
for i = 1:size(v1,1)
    scatter(ones(1,size(v1,2))*i, v1(i,:))
end
xticks(1:length(proficient))
xticklabels(names)
axis padded

subplot(2,2,3)
errorbar(nanmean(p2,2), sem(p2'), 'ok')
hold on
for i = 1:size(p2,1)
    scatter(ones(1,size(p2,2))*i, p2(i,:))
end
xticks(1:length(proficient))
xticklabels(names)
axis padded
ylim([0.6 1])
subplot(2,2,4)
errorbar(nanmean(v2,2), sem(v2'), 'ok')
hold on
for i = 1:size(v2,1)
    scatter(ones(1,size(v2,2))*i, v2(i,:))
end
xticks(1:length(proficient))
xticklabels(names)
axis padded



%%
training_block = nan(6,5);
for i = 1:length(training)
    tp = [training{i}.trials_expert];
    training_block(1:length(tp),i)  = tp;
end
