function pupil = extract_pupil_behavior(filename, thresh)

    % Rebecca Krall
    % 
    % This function is designed to take the .csv output of deeplabcut
    % (specifically singleAnimal_mouse_faceFeb15 network) and extract the
    % pupil diameter for each frame. It works by fitting an ellipse to the
    % points around the pupil with likelihoods above some threshold. NaN
    % placeholders are set for any failure to fit due to too few 
    % points. Given the way that we label the pupil, its also possible to
    % directly calculate diameter because each point lies directly across
    % from another point. I've commented out code to do this, but it may be
    % useful to attempt when fitting fails. 
    %
    % Inputs:
    %   filename - str, filename of the .csv file containing deeplabcut
    %       pose estimations
    %   thresh - double, a value that indicates what likelihood a given
    %       estimate must pass to be used to fit the ellipse

data_matrix = readmatrix(filename);

x = [1,4,7,10,13,16,19,22]+1;
y = x+1;
lik = x+2;

pupil_x = data_matrix(:, x);
pupil_y = data_matrix(:,y);
pupil_lik = data_matrix(:,lik);

if nargin < 2
    thresh = 0.80;
end

points = 5;


% The following code can be used as reference if you choose to directly
% estimate diameter by calculating the distance between points across from
% each other in the pose estimation. For reference:
%   1 - Top
%   2 - Bottom
%   3 - Left
%   4 - Right
%   5 - Top Left
%   6 - Bottom Right
%   7 - Top Right
%   8 - Bottom Left
% NOTE TO FUTURE BECCA: double check these orientations. 

% pupil_x(pupil_lik < thresh) = nan;
% pupil_y(pupil_lik < thresh)= nan;
% di(1,:) = sqrt(((pupil_x(:,2) - pupil_x(:,1)).^2) + ((pupil_y(:,2) - pupil_y(:,1)).^2));
% di(2,:) = sqrt(((pupil_x(:,4) - pupil_x(:,3)).^2) + ((pupil_y(:,4) - pupil_y(:,3)).^2));
% di(3,:) = sqrt(((pupil_x(:,6) - pupil_x(:,5)).^2) + ((pupil_y(:,6) - pupil_y(:,5)).^2));
% di(4,:) = sqrt(((pupil_x(:,8) - pupil_x(:,7)).^2) + ((pupil_y(:,8) - pupil_y(:,7)).^2));



for i=1:size(data_matrix,1)
    
    warning off
    goodPoints = (pupil_lik(i,:) > thresh);   
   
    
    if sum(goodPoints) > points
        pupil_points = [pupil_x(i,goodPoints); pupil_y(i,goodPoints)];
        try
            [~,a,b,~] = fitellipse(pupil_points);
            pupil_diameter = 2*max(a,b);
        catch
            %disp('fit ellipse failed')
            pupil_diameter = nan;
        end
    else
        pupil_diameter = nan;
    end
    
    
    
    pupil(i) = pupil_diameter;
    
end 