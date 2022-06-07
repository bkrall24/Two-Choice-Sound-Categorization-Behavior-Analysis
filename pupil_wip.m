edges = [0:0.05:1];
animal_choice = { 'c_124' ,'c_125', 'c_129', 'opto_69', 'opto_70', 'opto_96', 'opto_97'};
for i = 1:length(animal_choice)
    
    selpath = ['W:\Data\2AFC_Behavior\', animal_choice{i}];
    a{i} = analyze_animal(selpath);
    pupil = analyze_pupil(selpath);
    
    t = analyze_training(a{i});
    choose = false(1,length(a{i}.stimulus));
    choose(t.trials_proficient:end) = true;
    a{i} = select_trials(a{i}, choose);
    
    p = pupil.diameter ./ prctile(pupil.diameter, 99.9, 'all');
    p = nanmean(p(:,1:500),2);
    p = p(choose);
    pupils{i} = p;
    b{i} = discretize(p, edges);
end

%%
for i = 1:3
    animal = a{i};
    p = pupils{i};
    bins = b{i};
    
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
subplot(1,2,1)
errorbar(1:20, nanmean(easy(:,:,1)), sem(easy(:,:,1)))
hold on
errorbar(1:20, nanmean(easy(:,:,2)), sem(easy(:,:,2)))
axis padded
axis square

hard = squeeze(success(:,:,2,:));
subplot(1,2,2)
errorbar(1:20, nanmean(hard(:,:,1)), sem(hard(:,:,1)))
hold on
errorbar(1:20, nanmean(hard(:,:,2)), sem(hard(:,:,2)))
axis padded
axis square

%%
figure
easy = squeeze(rxn(:,:,1,:));
subplot(1,2,1)
errorbar(1:20, nanmean(easy(:,:,1)), sem(easy(:,:,1)))
hold on
errorbar(1:20, nanmean(easy(:,:,2)), sem(easy(:,:,2)))
axis padded
axis square

hard = squeeze(rxn(:,:,2,:));
subplot(1,2,2)
errorbar(1:20, nanmean(hard(:,:,1)), sem(hard(:,:,1)))
hold on
errorbar(1:20, nanmean(hard(:,:,2)), sem(hard(:,:,2)))
axis padded
axis square

%%
figure
easy = squeeze(nogo(:,:,1,:));
subplot(1,2,1)
errorbar(1:20, nanmean(easy(:,:,1)), sem(easy(:,:,1)))
hold on
errorbar(1:20, nanmean(easy(:,:,2)), sem(easy(:,:,2)))
axis padded
axis square

hard = squeeze(nogo(:,:,2,:));
subplot(1,2,2)
errorbar(1:20, nanmean(hard(:,:,1)), sem(hard(:,:,1)))
hold on
errorbar(1:20, nanmean(hard(:,:,2)), sem(hard(:,:,2)))
axis padded
axis square
