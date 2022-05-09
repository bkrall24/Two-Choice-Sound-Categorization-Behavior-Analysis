function psych = fit_psychometric_curve(xAxis, yData, toFig, color)

    % Rebecca Krall 01/18/21
    
    % Adapted from code from this blog post:
    % http://matlaboratory.blogspot.co.uk/2015/05/fitting-better-psychometric-curve.html
    % 
    % Inputs:
    %   xAxis - numerical array of x values to be fit
    %      In cases of tosca two-choice lick behavior, it is the different
    %      stimuli played.
    %   yData - numerical array of y values to be fit
    %       In tosca two-choice lick behavior, it is the proportion the
    %       animal licked to one side for each stimuli in xAxis. Note to
    %       fit correctly, it should be the that the animal is licking the
    %   toFig - boolean value, if true it plots the data
    %   color - only necessary if toFig is true, sets the color for the
    %       plots
    %
    % Outputs:
    %   ffit - matlab cfit object containing the fitted model, parameters
    %       and confidence intervals
    %   curve - n x 2 numerical array containing a smooth curve plotted
    %       over the xAxis range. n = length(xAxis)*50
    
    
    % If no arguments are passed to toFig or color, they are defaulted to
    % false and 'k'
    if nargin == 2
        toFig = false;
        color = 'k';
    elseif nargin == 3
        color = 'k';
    end
    
    % This assumes that your xAxis data will have 9 points and the 5th
    % point would correspond to the center of the curve in an ideal
    % situation
    if length(xAxis) == 9
        SP = [0.05, 0.05, xAxis(5), xAxis(8)- xAxis(7)];
        LM = [0, 0, 0, 0];
        UL = [0.5, 0.5, xAxis(9), xAxis(9)- xAxis(1)];
    else
        SP = [0.05, 0.05, median(xAxis), median(xAxis)/2];
        LM = [0, 0, 0, 0];
        UL = [0.5, 0.5, max(xAxis), range(xAxis)];
    end

    % Transpose data if necessary
    if size(xAxis,1) < size(xAxis,2)
        xAxis=xAxis';
    end
    if size(yData,1)<size(yData,2)
        yData=yData';
    end

    % Check range of data - this maybe doesn't have to work this way.
    % Original code attempted to normalize to 0 - 1, which can be
    % implemented again 
    if min(yData)<0 || max(yData)>1  
         error('Data not normalized to 0-1 range');
    end
    
    % Prepare fitting function
    F=@(low_lapse,high_lapse,bias,threshold,x) low_lapse+(1-low_lapse-high_lapse)*0.5*(1+erf((x-bias)/threshold));

    % Fit data
    ffit=fit(xAxis,yData,F,'StartPoint',SP,'Upper',UL,'Lower',LM);


    % Create a new xAxis with higher resolution
    fineX = linspace(min(xAxis),max(xAxis),numel(xAxis)*50);
    
    % Generate curve from fit
    curve = feval(ffit, fineX);
    curve = [fineX', curve];
    
  
    
    psych.fit = ffit;
    psych.curve = curve;
    psych.xAxis = xAxis;
    psych.yData = yData; 
    
    if toFig        
        plot_single_psychometric_curve(psych, color)
    end
    
end