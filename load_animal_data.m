function [animal, ids, early, ttl, training, names] = load_animal_data(early_window)
    
    groups = dir('C:\Users\natet\Desktop\Experimental_Data');
    groups = groups(~contains({groups.name}, '.'));
    [indx,~] = listdlg('ListString',{groups.name});
    groups = groups(indx);
    
    paths = [];
    names = [];
    ids = [];
    for i = 1:length(groups)
        files = dir(strcat(groups(i).folder,'\', groups(i).name));
        files = files(~contains({files.name}, '.'));
        
        filepaths = arrayfun(@(x) strcat(x.folder, '\', x.name), files, 'UniformOutput', false);
        names = cat(1, names, {files.name}');
        paths = cat(1, paths, filepaths);
        ids  = cat(1, ids, repmat({groups(i).name}, size(filepaths)));
    end
    
    

    animal = cellfun(@analyze_animal, paths);
    ttl = cellfun(@(x) analyze_trial_info(false, x), paths);
    ttl2 = cellfun(@(x) analyze_trial_info(true, x), paths);

    if nargin == 0
        early_window = 750:825;
    end
    

    early = animal;
    for i = 1:length(animal)
        [choice, rxnTime] = rescore_animal(ttl2(i),early_window);
        early(i).lick = choice;
        early(i).rxnTime = rxnTime;
    end
    
    training = arrayfun(@analyze_training, animal);


end
