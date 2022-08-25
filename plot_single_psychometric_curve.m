function plot_single_psychometric_curve(psych, color, errorbars)

    if nargin == 1
        color = 'k';
    end   
            
    
    plot(psych.curve(:,1), psych.curve(:,2), 'color', color)
    hold on
    %scatter(psych.xAxis, psych.yData, 'MarkerEdgeColor', color);

    set(gca, 'XScale', 'log')
    axis square
    set(gca, 'Xlim', [psych.xAxis(1)-0.1, psych.xAxis(end)+1])
    xticks(round(psych.xAxis))
    if length(psych.xAxis) == 9
        xline(psych.xAxis(5), ':');
    end
    yline(.5, ':');
    ylim([0 1])
    
    if nargin > 2
        errorbar( psych.xAxis, psych.yData, errorbars(:,1)- psych.yData, errorbars(:,2)- psych.yData, 'LineStyle', 'None', 'color', color);
    end
    
end