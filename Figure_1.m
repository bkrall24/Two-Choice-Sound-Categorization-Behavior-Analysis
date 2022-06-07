% Figure 1

%% Example data
example_mouse = analyze_animal('W:\Data\2AFC_Behavior\c_124');
t = analyze_training(example_mouse);
sig = 500;

%% Plot Training Trajectory of Easy and Hard stimuli trials
figure
set(gcf, 'Position',  [1001 682 691 657])
set(gcf,'renderer','painter','color',[1 1 1]);
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

% text(length(example_mouse.sessionNum)-200, 0.625, 'Easy', 'color', 'b', 'HorizontalAlignment', 'right')
% text(length(example_mouse.sessionNum)-200, 0.55, 'Hard', 'color', 'r', 'HorizontalAlignment', 'right')


% Show psychometric curves from early, mid, and late training - indicate on the trajectories where the data is from
subplot(3,3,4)
lastInd = find(example_mouse.sessionNum == 12, 1, 'last');
% [xAxis, yData, errorbars] = generate_psych_data( ...
%     example_mouse.lick(:,example_mouse.sessionNum == 12), ...
%     example_mouse.stimulus(example_mouse.sessionNum == 12));

[xAxis, yData, errorbars] = generate_psych_data( ...
    example_mouse.lick(:,lastInd -sig:lastInd), ...
    example_mouse.stimulus(lastInd -sig:lastInd));
psych = fit_psychometric_curve(xAxis, yData, false);
plot_single_psychometric_curve(psych, 'k', errorbars)
ylabel('Proportion Lick Right')
xlabel('Frequency (Hz)')
title('Early ')

subplot(3,3,1:3)
hold on
[~, marker_early] = min(abs(x - lastInd));
scatter(lastInd, y(marker_early), 'ok')

subplot(3,3,5)
lastInd = find(example_mouse.sessionNum == 17, 1, 'last');
% [xAxis, yData, errorbars] = generate_psych_data( ...
%     example_mouse.lick(:,example_mouse.sessionNum == 17), ...
%     example_mouse.stimulus(example_mouse.sessionNum == 17));

[xAxis, yData, errorbars] = generate_psych_data( ...
    example_mouse.lick(:,lastInd -sig:lastInd), ...
    example_mouse.stimulus(lastInd -sig:lastInd));
psych = fit_psychometric_curve(xAxis, yData, false);
plot_single_psychometric_curve(psych, 'k', errorbars)
ylabel('Proportion Lick Right')
xlabel('Frequency (Hz)')
title('Mid ')

subplot(3,3,1:3)
hold on
[~, marker_mid] = min(abs(x - lastInd));
scatter(lastInd, y(marker_mid), 'ok')


subplot(3,3,6)
lastInd = find(example_mouse.sessionNum == 22, 1, 'last');
% [xAxis, yData, errorbars] = generate_psych_data( ...
%     example_mouse.lick(:,example_mouse.sessionNum == 22), ...
%     example_mouse.stimulus(example_mouse.sessionNum == 22));

[xAxis, yData, errorbars] = generate_psych_data( ...
    example_mouse.lick(:,lastInd -sig:lastInd), ...
    example_mouse.stimulus(lastInd -sig:lastInd));
psych = fit_psychometric_curve(xAxis, yData, false);
plot_single_psychometric_curve(psych, 'k', errorbars)
ylabel('Proportion Lick Right')
xlabel('Frequency (Hz)')
title('Late ')

subplot(3,3,1:3)
hold on
[~, marker_late] = min(abs(x - lastInd));
scatter(lastInd, y(marker_late), 'ok')


% Plot the change in reaction time over the course of training for easy and hard stimuli

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
% text(length(example_mouse.sessionNum)-200, 400, 'Easy', 'color', 'b', 'HorizontalAlignment', 'right')
% text(length(example_mouse.sessionNum)-200, 360, 'Hard', 'color', 'r', 'HorizontalAlignment', 'right')
plot(diff(example_mouse.sessionNum)*1000, ':', 'color', [0.5 0.5 0.5])
ylim([200 450])
xlim([start length(example_mouse.sessionNum)])


%%
control = get_animal_array;


%%
figure
set(gcf,'renderer','painter','color',[1 1 1]);
subplot(2,2,1:2)
hold on
for i = 1:length(control)
    t(i) = analyze_training(control(i));

    [d_x, d_y] = get_performance_trajectory(control(i), "easy", 200);
    plot(d_x, d_y, 'color', [0 0 0 0.5])
    hold on
  
        
end

%shadedErrorBar(sig:2500, nanmean(norm_y), sem(norm_y), 'b', 1)
yline(0.85, ':')
xlabel('Trials')
ylabel('Success Rate (Easy)')
xlim([sig,5000])
ylim([0.5, 1])
set(gcf,'renderer','painter','color',[1 1 1]);



subplot(2,2,3)
errorbar(1, nanmean([t.trials_proficient]), sem([t.trials_proficient]'),'_k')
hold on
scatter(ones(1, length([t.trials_proficient])), [t.trials_proficient],'k')
errorbar(2, nanmean([t.trials_expert]), sem([t.trials_expert]'),'_k')
scatter(ones(1, length([t.trials_expert]))*2, [t.trials_expert],'k')
xticks([1,2])
xticklabels({'Proficient', 'Expert'})
xlim([0.75 2.25])
title('Trials till Threshold')
axis square



subplot(2,2,4)
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
axis square


%% average performance after proficient on easy trials, variance 

for i = 1:length(control)
    choose_training_period = false(length(control(i).stimulus),1);
    choose_training_period(t(i).trials_proficient:end) = true;
    choose_trials = control(i).stimulus < 4 | control(i).stimulus > 16;
    a = select_trials(control(i),  choose_training_period' & choose_trials)
    perf{i} = splitapply(@(x) sum(x([1,2],:), 'all')./sum(x(1:4,:), 'all'), a.lick, a.sessionNum - min(a.sessionNum)+1)
    
end

p1 = cellfun(@nanmean, perf)
v1 = cellfun(@var, perf)




%% average performance after expert on all trials, variance
for i = 1:length(control)
    choose_training_period = false(length(control(i).stimulus),1);
    choose_training_period(t(i).trials_expert:end) = true;
    choose_trials = control(i).stimulus >= 4 | control(i).stimulus <= 16;
    a = select_trials(control(i),  choose_training_period' & choose_trials)
    perf{i} = splitapply(@(x) sum(x([1,2],:), 'all')./sum(x(1:4,:), 'all'), a.lick, a.sessionNum - min(a.sessionNum)+1)
    
end

p2 = cellfun(@nanmean, perf)
v2 = cellfun(@var, perf)


%%
subplot(1,2,1)
errorbar(1, nanmean(p1), sem(p1'), 'ok')
hold on
scatter(ones(1, length(p1)), p1,  'ok', 'MarkerEdgeAlpha', 0.4)
errorbar(2, nanmean(p2), sem(p2'), 'ok')
hold on
scatter(ones(1, length(p2))*2, p2,  'ok', 'MarkerEdgeAlpha', 0.4)
xlim([0.75 2.25])
xticks([1 2])
ylim([0.85 1])
xticklabels({'Easy Trials', 'Hard Trials'})
title('Average Performance Across Sessions')
axis square

subplot(1,2,2)
errorbar(1, nanmean(v1), sem(v1'), 'ok')
hold on
scatter(ones(1, length(v1)), v1,  'ok', 'MarkerEdgeAlpha', 0.4)
errorbar(2, nanmean(v2), sem(v2'), 'ok')
hold on
scatter(ones(1, length(v2))*2, v2,  'ok', 'MarkerEdgeAlpha', 0.4)
xlim([0.75 2.25])
xticks([1 2])
xticklabels({'Easy Trials', 'Hard Trials'})
title('Variance across Sessions')
axis square


