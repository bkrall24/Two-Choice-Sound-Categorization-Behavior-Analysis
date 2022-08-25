% extracting data from lick data

% frequency
    overall_frequency = squeeze(sum(diff(tInfo.lick, 1, 2) == 1, 2))./2;
    % during stimulus
    stimulus_frequency = squeeze(sum(diff(tInfo.lick(:,500:1000,:)) == 1, 2))./1;
    % before stimulus
    anticipatory_frequency = squeeze(sum(diff(tInfo.lick(:, 250:500,:)) == 1, 2))./0.5;
    
    % in the 200 ms when stim is on but reactions don't mean anything
    stim_anticipatory = squeeze(sum(diff(tInfo.lick(:,1:100, :)) == 1, 2))./.2;

% duration 
    
    for i = 1:size(tInfo.lick,1)
        durations{i,1} = diff(find(diff(tInfo.lick(i,:,1))))/500;
        durations{i,2} = diff(find(diff(tInfo.lick(i,:,2))))/500;
    end
    % average duration
    mean_durations = cellfun(@nanmean, durations);
    
    % distribution of lick durations
    all_left = [durations{:,1}];
    all_right = [durations{:,2}];
    
    
    all_noLed = [durations{~logical(animal.LED)}];
    all_Led = [durations{logical(animal.LED)}];

% total time licking
    % function of those two factors - will account for fast/constant lick
    % behavior
    lick_time = cellfun(@sum, durations)
    
    
    %%
    hits = sum(animal.lick(1:2,:)) == 1;
misses = sum(animal.lick(3:4, :)) == 1;

LED = logical(animal.LED);

lefts = sum(animal.lick([1,3],:)) == 1;
rights = sum(animal.lick([2,4],:)) == 1;

% Combinatorial plotting of all the data about lick rasters to get a sense
% of whats happening

lowside = mode(animal.target(animal.stimulus == 2))+1;

if lowside == 1
    lefts = sum(animal.lick([1,3],:)) == 1;
    rights = sum(animal.lick([2,4],:)) == 1;
else
    lefts = sum(animal.lick([1,3],:)) == 1;
    rights = sum(animal.lick([2,4],:)) == 1;
end

left_lick = tInfo.lick1;
right_lick = tInfo.lick2;

%%
figure

subplot(6,2,1)
plot(nanmean(tInfo.lick1(hits&~LED,:)))
hold on
plot(nanmean(tInfo.lick1(hits&LED,:)))
title('All Hits')
% plot(500:1500, ones(1, 1001) * 0.4, 'g')
% ylim([0 0.45])


subplot(6,2,2)
plot(nanmean(tInfo.lick2(hits&~LED,:)))
hold on
plot(nanmean(tInfo.lick2(hits&LED,:)))
title('All Hits')
% plot(500:1500, ones(1, 1001) * 0.4, 'g')
% ylim([0 0.45])


subplot(6,2,3)
plot(nanmean(tInfo.lick1(misses&~LED,:)))
hold on
plot(nanmean(tInfo.lick1(misses&LED,:)))
title('All Misses')
%plot(500:1500, ones(1, 1001) * 0.4, 'g')


subplot(6,2,4)
plot(nanmean(tInfo.lick2(misses&~LED,:)))
hold on
plot(nanmean(tInfo.lick2(misses&LED,:)))
title('All Misses')
% plot(500:1500, ones(1, 1001) * 0.4, 'g')
% ylim([0 0.45])


subplot(6,2,5)
plot(nanmean(tInfo.lick1(hits&rights&~LED,:)))
hold on
plot(nanmean(tInfo.lick1(hits&rights&LED,:)))
title('Right Hits')
% plot(500:1500, ones(1, 1001) * 0.4, 'g')
% ylim([0 0.45])

subplot(6,2,6)
plot(nanmean(tInfo.lick2(hits&rights&~LED,:)))
hold on
plot(nanmean(tInfo.lick2(hits&rights&LED,:)))
title('Right Hits')
% plot(500:1500, ones(1, 1001) * 0.4, 'g')
% ylim([0 0.45])


subplot(6,2,7)
plot(nanmean(tInfo.lick1(misses&rights&~LED,:)))
hold on
plot(nanmean(tInfo.lick1(misses&rights&LED,:)))
title('Right Misses')
% plot(500:1500, ones(1, 1001) * 0.4, 'g')
% ylim([0 0.45])


subplot(6,2,8)
plot(nanmean(tInfo.lick2(misses&rights&~LED,:)))
hold on
plot(nanmean(tInfo.lick2(misses&rights&LED,:)))
title('Right Misses')
% plot(500:1500, ones(1, 1001) * 0.4, 'g')
% ylim([0 0.45])



subplot(6,2,9)
plot(nanmean(tInfo.lick1(hits&lefts&~LED,:)))
hold on
plot(nanmean(tInfo.lick1(hits&lefts&LED,:)))
title('Left Hits')
% plot(500:1500, ones(1, 1001) * 0.4, 'g')
% ylim([0 0.45])

subplot(6,2,10)
plot(nanmean(tInfo.lick2(hits&lefts&~LED,:)))
hold on
plot(nanmean(tInfo.lick2(hits&lefts&LED,:)))
title('Left Hits')
% plot(500:1500, ones(1, 1001) * 0.4, 'g')
% ylim([0 0.45])

subplot(6,2,11)
plot(nanmean(tInfo.lick1(misses&lefts&~LED,:)))
hold on
plot(nanmean(tInfo.lick1(misses&lefts&LED,:)))
title('Left Misses')
% plot(500:1500, ones(1, 1001) * 0.4, 'g')
% ylim([0 0.45])


subplot(6,2,12)
plot(nanmean(tInfo.lick2(misses&lefts&~LED,:)))
hold on
plot(nanmean(tInfo.lick2(misses&lefts&LED,:)))
title('Left Misses')
% plot(500:1500, ones(1, 1001) * 0.4, 'g')
% ylim([0 0.45])

