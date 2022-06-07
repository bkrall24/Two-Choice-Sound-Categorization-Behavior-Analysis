% Potentiatl Supplemental Informatin

%% different reaction times to different stimuli

control = get_animal_array;

for i = 1:length(control)
    rxn = control(i).rxnTime;
    rxn_choice = rxn > 200;
    t = analyze_training(control(i));
    choice = false(1, length(control(i).stimulus));
    choice(t.trials_proficient:length(control(i).stimulus)) = true;
    [r(i,:), stim(i,:)] = calculate_means(rxn(rxn_choice & choice), control(i).stimulus(rxn_choice&choice), 'all');
end


errorbar(nanmean(r), sem(r), 'color', [0 0 0])
hold on
plot(r', 'color', [0 0 0 0.2])
axis square
axis padded
xticklabels(stim(1,:))


%% Relationship between reaction time and percent correct 
s =[];
r = [];
b = [];
for i = 1:length(traj)
    for j = 1:length(traj{i})
        animal = traj{i}(j);
        go = logical(sum(animal.lick([1:4],:)));
        easy = animal.stimulus > 16
        go_animal = select_trials(animal, go & easy);

        bins = generate_bins(length(go_animal.stimulus), 500);
        
        rxn = splitapply(@nanmean, go_animal.rxnTime, bins);
        r = cat(2, r, rxn);
        success = splitapply(@(x) sum(x(1:2,:), 'all')./length(x), go_animal.lick, bins);
        s = cat(2, s, success)
        
        b = cat(2, b, 1:max(bins))
        %(success, rxn)
        hold on
    end
end
scatter(s,r)

x = s;
y = r;

p = polyfit(x,y,1)
yfit = polyval(p,x);
yresid = y - yfit;
SSresid = sum(yresid.^2);
SStotal = (length(y)-1) * var(y)
rsq = 1 - SSresid/SStotal


