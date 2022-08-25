function [animal_array, animal_id] = get_animal_array()

    [filenames] = uigetdir2('W:\Data\2AFC_Behavior');
    for i= 1:length(filenames)
        animal_array(i) = analyze_animal(filenames{i});
        p_f = split(filenames{i}, '\');
        animal_id(i) = p_f(end);
    end
    
    
end