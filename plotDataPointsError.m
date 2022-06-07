function plotDataPointsError(x, ind,color, line, scatterOn)
    if nargin < 2 
        ind = 1:size(x, 2);
    end
    if nargin < 3
        color = [0 0 0];
        line = true;
        scatterOn = true;
    end
    if ind == 0
        ind = 1:size(x, 2);
    end
    
    if numel(x) == numel(ind)
        err = nan(size(x));
        y = x;
    else
        err = std(x, 'omitnan')./sqrt(length(x));
        y = nanmean(x);
    end
    
    color2 = (color*3+14)./17;
    for i = 1:length(ind)
        if scatterOn
            
            scatter(ones(size(x,1),1)*ind(i), x(:,i),  'o',  'MarkerFaceColor', color2, 'MarkerEdgeColor',color2)%  'MarkerFaceAlpha', 0.1, 'MarkerEdgeColor', color, 'MarkerEdgeAlpha', 0.1)
            hold on
        end
        
    end
   
    if line
        plot(ind, x', 'color', color2)
        hold on
    end
    
    errorbar(ind,y,err,'o', 'color', color,'MarkerFaceColor', color);
    %xticks(ind)
    axis padded
end


