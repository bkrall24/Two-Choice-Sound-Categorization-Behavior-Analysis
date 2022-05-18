% Code to generate figures

%% Fig. 1: 
%   Mice learn to categorize amplitude modulated noise 

% Fig 1A: Schematic of behavioral setup 
% Fig 1B: Schematic of behavioral trial
% Fig 1C: Example trace of performance on easy and hard trials 
% Fig 1D: Example psychometric curves early, mid, and late
% Fig 1E: Example of reduction of reaction times over the course of
% learning

example_mouse = c124;
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


set(gcf,'renderer','painter','color',[1 1 1]);

%% Fig 2: 
%   Inhibiting excitatory neurons en masse reduces accurate categorization
%   of AM noise. However, inhibition of individual projection neuron types
%   does not impact performance

% Fig 2A: Schematic of LED setup
% Fig 2B: 

control = get_animal_array;
CAMKII = get_animal_array;
PT = get_animal_array;
IT = get_animal_array;
CT = get_animal_array;




%% Fig 3: 
%   Inhibition of projection neurons impairs the rate of learning AM noise
%   categorization

