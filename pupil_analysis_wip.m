% population analysis for comparing pupil to performance

% pseudo code
%
% generate a list of animals to analyze
% for loop through the list of animals
% load animal, pupil
% select proficient trials
% select same trials of the pupil data
% normalize the pupil data to prcntile 99
% average across some period (1:500) 
edges = [0:0.05:1];
%animal_choice = { 'c_124' ,'c_125', 'c_129', 'opto_69', 'opto_70', 'opto_96', 'opto_97'};
animal_choice = { 'opto_96', 'opto_97'};
for i = 1:length(animal_choice)
    
    selpath = ['W:\Data\2AFC_Behavior\', animal_choice{i}];
    animal = analyze_animal(selpath);
    pupil = analyze_pupil(selpath);
    
    t = analyze_training(animal);
    choose = false(1,length(animal.stimulus));
    choose(t.trials_proficient:end) = true;
    animal = select_trials(animal, choose);
    
    p = pupil.diameter ./ prctile(pupil.diameter, 99.9, 'all');
    p = nanmean(p(:,1:500),2);
    p = p(choose);
    
    bins = discretize(p, edges);
    
    %bins = discretize(p, 10);
    
    for j = 1:20
        off = (bins == j)' & ~animal.LED;
        on = (bins == j)' & animal.LED;
        rxn_choice = animal.rxnTime > 0;
        
        if sum(off) > 20
            success(i,j,:,1) = calculate_percentages(animal.lick(:,off), animal.stimulus(off), 'easy', 'Hits');
            nogo(i,j,:,1) = calculate_percentages(animal.lick(:,off), animal.stimulus(off), 'easy', 'No Go');
            if sum(off & rxn_choice) > 20
                rxn(i,j,:,1) = calculate_means(animal.rxnTime(off & rxn_choice), animal.stimulus(off& rxn_choice), 'easy');
            else
                rxn(i,j,:,1) = nan;
            end
        else
            success(i,j,:,1) = [nan, nan, nan];
            rxn(i,j,:,1) = [nan, nan, nan];
            nogo(i,j,:,1) = [nan, nan, nan];
        end
        if sum(on) > 20
            success(i,j,:,2) = calculate_percentages(animal.lick(:,on), animal.stimulus(on), 'easy', 'Hits');
            nogo(i,j,:,2) = calculate_percentages(animal.lick(:,on), animal.stimulus(on), 'easy', 'No Go');
            if sum(on & rxn_choice) > 20
                rxn(i,j,:,2) = calculate_means(animal.rxnTime(on & rxn_choice), animal.stimulus(on& rxn_choice), 'easy');
            else
                rxn(i,j,:,2) = nan;
            end
        else
            success(i,j,:,2) = [nan, nan, nan];
            rxn(i,j,:,2) = [nan, nan, nan];
            nogo(i,j,:,1) = [nan, nan, nan];
        end
    end
end


%%
figure
easy = squeeze(success(:,:,1,:));
subplot(1,3,1)
errorbar(0.05:0.05:1, nanmean(easy(:,:,1)), sem(easy(:,:,1)))
hold on
errorbar(0.05:0.05:1, nanmean(easy(:,:,2)), sem(easy(:,:,2)))
axis padded
axis square

hard = squeeze(success(:,:,2,:));
subplot(1,3,2)
errorbar(0.05:0.05:1, nanmean(hard(:,:,1)), sem(hard(:,:,1)))
hold on
errorbar(0.05:0.05:1, nanmean(hard(:,:,2)), sem(hard(:,:,2)))
axis padded
axis square

hard = squeeze(success(:,:,3,:));
subplot(1,3,3)
errorbar(0.05:0.05:1, nanmean(hard(:,:,1)), sem(hard(:,:,1)))
hold on
errorbar(0.05:0.05:1, nanmean(hard(:,:,2)), sem(hard(:,:,2)))
axis padded
axis square

%%
figure
easy = squeeze(rxn(:,:,1,:));
subplot(1,3,1)
errorbar(0.05:0.05:1, nanmean(easy(:,:,1)), sem(easy(:,:,1)))
hold on
errorbar(0.05:0.05:1, nanmean(easy(:,:,2)), sem(easy(:,:,2)))
axis padded
axis square

hard = squeeze(rxn(:,:,2,:));
subplot(1,3,2)
errorbar(0.05:0.05:1, nanmean(hard(:,:,1)), sem(hard(:,:,1)))
hold on
errorbar(0.05:0.05:1, nanmean(hard(:,:,2)), sem(hard(:,:,2)))
axis padded
axis square

hard = squeeze(rxn(:,:,3,:));
subplot(1,3,3)
errorbar(0.05:0.05:1, nanmean(hard(:,:,1)), sem(hard(:,:,1)))
hold on
errorbar(0.05:0.05:1, nanmean(hard(:,:,2)), sem(hard(:,:,2)))
axis padded
axis square

%%
figure
easy = squeeze(nogo(:,:,1,:));
subplot(1,2,1)
errorbar(0.05:0.05:1, nanmean(easy(:,:,1)), sem(easy(:,:,1)))
hold on
errorbar(0.05:0.05:1, nanmean(easy(:,:,2)), sem(easy(:,:,2)))
axis padded
axis square

hard = squeeze(nogo(:,:,2,:));
subplot(1,2,2)
errorbar(0.05:0.05:1, nanmean(hard(:,:,1)), sem(hard(:,:,1)))
hold on
errorbar(0.05:0.05:1, nanmean(hard(:,:,2)), sem(hard(:,:,2)))
axis padded
axis square


%%
% population analysis for comparing pupil to performance

% pseudo code
%
% generate a list of animals to analyze
% for loop through the list of animals
% load animal, pupil
% select proficient trials
% select same trials of the pupil data
% normalize the pupil data to prcntile 99
% average across some period (1:500) 
edges = [0:0.05:1];
animal_choice = { 'opto_69', 'opto_70'};
for i = 1:length(animal_choice)
    
    selpath = ['W:\Data\2AFC_Behavior\', animal_choice{i}];
    animal = analyze_animal(selpath);
    pupil = analyze_pupil(selpath);
    
    t = analyze_training(animal);
    choose = false(1,length(animal.stimulus));
    choose(t.trials_proficient:end) = true;
    animal = select_trials(animal, choose);
    
    p = pupil.diameter ./ prctile(pupil.diameter, 99.9, 'all');
    p = nanmean(p(:,1:500),2);
    p = p(choose);
    
    bins = discretize(p, edges);
    %bins = discretize(p, 10);
    
    for j = 1:20
        off = (bins == j)' & ~animal.LED;
        on = (bins == j)' & animal.LED;
        rxn_choice = animal.rxnTime > 0;
        
        if sum(off) > 20
            success(i,j,1) = calculate_percentages(animal.lick(:,off), animal.stimulus(off), 'f', 'Hits');
            nogo(i,j,1) = calculate_percentages(animal.lick(:,off), animal.stimulus(off), 'f', 'No Go');
            if sum(off & rxn_choice) > 20
                rxn(i,j,1) = calculate_means(animal.rxnTime(off & rxn_choice), animal.stimulus(off& rxn_choice), 'f');
            else
                rxn(i,j,1) = nan;
            end
        else
            success(i,j,1) = nan;
            rxn(i,j,1) = nan;
            nogo(i,j,1) = nan;
        end
        if sum(on) > 20
            success(i,j,2) = calculate_percentages(animal.lick(:,on), animal.stimulus(on), 'f', 'Hits');
            nogo(i,j,2) = calculate_percentages(animal.lick(:,on), animal.stimulus(on), 'f', 'No Go');
            if sum(on & rxn_choice) > 20
                rxn(i,j,2) = calculate_means(animal.rxnTime(on & rxn_choice), animal.stimulus(on & rxn_choice), 'f');
            else
                rxn(i,j,2) = nan;
            end
        else
            success(i,j,2) =nan;
            rxn(i,j,2) = nan;
            nogo(i,j,2) = nan;
        end
    end
end
%%
subplot(1,3,1)
easy = success;
errorbar(0.05:0.05:1, nanmean(easy(:,:,1)), sem(easy(:,:,1)))
hold on
errorbar(0.05:0.05:1, nanmean(easy(:,:,2)), sem(easy(:,:,2)))
axis padded
axis square
title('Success Rate (all trials)')
ylabel('proportion correct')
xlabel('Pupil bin')




subplot(1,3,2)
easy = rxn;
errorbar(0.05:0.05:1, nanmean(easy(:,:,1)), sem(easy(:,:,1)))
hold on
errorbar(0.05:0.05:1, nanmean(easy(:,:,2)), sem(easy(:,:,2)))
axis padded
axis square
title('Reaction Time')
ylabel('Time (ms)')
xlabel('Pupil bin')



subplot(1,3,3)
easy = nogo;
errorbar(0.05:0.05:1, nanmean(easy(:,:,1)), sem(easy(:,:,1)))
hold on
errorbar(0.05:0.05:1, nanmean(easy(:,:,2)), sem(easy(:,:,2)))

axis padded
axis square
title('No Go Rate')
ylabel('proportion no go')
xlabel('Pupil bin')
xlim([0.4, 1])
