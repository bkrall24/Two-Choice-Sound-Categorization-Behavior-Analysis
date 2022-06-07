%% Fig 3: The effect of LED changes over the course of training

% population effect on bias with LED on versus off - either some continuous plot (movsum) or binned
% bin the data relative to proficient to determine 'stages' of learning based on LED effect and plot the effect of LED at each stage
%

num_groups = 1;
for i = 1:num_groups
    group = get_animal_array;
    
    names(i) = inputdlg('Group Name');
    for j = 1:length(group)
        tc = analyze_training(group(j));
        choose = false(1,length(group(j).stimulus));
        choose(tc.trials_opto: length(group(j).stimulus)) = true;    
        animal(j) = select_trials(group(j), choose);
       
        train(j) = tc;
    end
    
    groups{i} = animal;
    training{i} = train;
    clear animal
    clear train
    
end


%%
% Calculate a rolling window (sigma 500 trials) of the left versus right
% bias for each animal

for i = 1:length(groups)
    a = groups{i};
    sig = 1000;
    
    for j = 1:length(a)
        figure
        lick = a(j).lick;
        led = a(j).LED;
        hard = ~(a(j).stimulus <= 16 & a(j).stimulus >= 4);
        x = 1:length(a(j).LED);
        highSide = mode(groups{i}(j).target(groups{i}(j).stimulus == 32));
        lefts = sum(movsum(lick([2,3],logical(led & hard))',[sig, 0])');
        rights = sum(movsum(lick([1,4],logical(led & hard))',[sig, 0])');
        totals = sum(movsum(lick([1:4],logical(led & hard))',[sig, 0])');
        if highSide == 1
            bias = (lefts - rights)./totals;
        else
            bias = (rights - lefts)./totals;
        end
        
        plot(x(logical(led & hard)), bias);
        hold on
        
        lefts = sum(movsum(lick([2,3],logical(~led & hard))',[sig, 0])');
        rights = sum(movsum(lick([1,4],logical(~led & hard))',[sig, 0])');
        totals = sum(movsum(lick([1:4],logical(~led & hard))',[sig, 0])');
         if highSide == 1
            bias2 = (lefts - rights)./totals;
        else
            bias2 = (rights - lefts)./totals;
         end
        
        plot(x(logical(~led & hard)), bias2);
        hold on
        
        %first_psych = splitapply(@(x) sum(x == 8), a(j).stimulus, a(j).sessionNum - min(a(j).sessionNum)+1)
        %session = find(first_psych > 15, 1, 'first') + min(a(j).sessionNum) - 1;
        %p = find(a(j).sessionNum == session ,1, 'first')
        %p = training{i}(j).trials_expert
        %xline(p)
        yline(0, ':')
    end
end

%%

% bin the data as percent trained to proficient
for i = 1:length(groups)
   
    
    for j = 1:length(groups{i})
        bins = generate_bins(length(groups{i}(j).stimulus), 1000);
       prof_bin(i,j) = bins(training{i}(j).trials_proficient);
        
%         first_psych = splitapply(@(x) sum(x == 8), groups{i}(j).stimulus,  groups{i}(j).sessionNum - min( groups{i}(j).sessionNum)+1)
%         session = find(first_psych > 20, 1, 'first') + min( groups{i}(j).sessionNum) - 1;
%         p = find( groups{i}(j).sessionNum == session ,1, 'first')
%          prof_bin(i,j) = bins(p);
         
        led = logical(groups{i}(j).LED);
        highSide = mode(groups{i}(j).target(groups{i}(j).stimulus == 32));
        for k = 1:max(bins)
            
            bias(k,1) = calculate_bias(groups{i}(j).lick(:, bins == k & led), highSide);
            bias(k,2) = calculate_bias(groups{i}(j).lick(:, bins == k & ~led), highSide);
        end
        b{i,j} = bias;
    end
    clear bias
end


%%
for i = 1:length(prof_bin)
    bb = b{i};
    bin = prof_bin(i);
    
    group_bias(i,:,:) = bb(bin - 1:bin+1,:)
end

    



%%
plot(squeeze(nanmean(x,1)))
hold on
plot(squeeze(x(:,:,1))', 'color', [0 0 1 0.2])