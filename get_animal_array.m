function [animal_array, filenames] = get_animal_array()

    [filenames] = uigetdir2('W:\Data\2AFC_Behavior');
    for i= 1:length(filenames)
        animal_array(i) = analyze_animal(filenames{i});
    end
    
    
end