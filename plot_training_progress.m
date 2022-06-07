function plot_training_progress(name, sig, LED)
     
    
    
    if ~LED
        figure
        subplot(4,1,1)
        [x,y] = get_performance_trajectory(name, 'easy', sig);
        plot(x(sig:end),y(sig:end),'b')
        hold on
        [x,y] = get_performance_trajectory(name, 'hard', sig);
        plot(x(sig:end),y(sig:end),'r')
        hold on
        [x,y] = get_performance_trajectory(name, 'discriminable', sig);
        plot(x(sig:end),y(sig:end),'k')
        plot(diff(name.sessionNum), ':', 'color', [0.5 0.5 0.5])
        xlim([0 length(name.sessionNum)])
        ylim([0.4 1])
        yline(0.85, ':')
        title('Easy verus Hard versus Discriminable')
        ylabel('Success Rate')
        xlabel('Trials')
        text(length(name.sessionNum)-50, 0.45, 'Easy', 'color', 'b', 'HorizontalAlignment', 'right')
        text(length(name.sessionNum)-50, 0.55, 'Hard', 'color', 'r', 'HorizontalAlignment', 'right')
        text(length(name.sessionNum)-50, 0.65, 'Discriminable', 'color', 'k', 'HorizontalAlignment', 'right')


        subplot(4,1,2)
        [x,y] = get_performance_trajectory(name, 'low', sig);
        plot(x(sig:end),y(sig:end),'b')
        hold on
        [x,y] = get_performance_trajectory(name, 'high', sig);
        plot(x(sig:end),y(sig:end),'r')
        hold on
        plot(diff(name.sessionNum), ':', 'color', [0.5 0.5 0.5])
        xlim([0 length(name.sessionNum)])
        ylim([0.4 1])
        yline(0.85, ':')
        title('Low versus High')
        ylabel('Reaction Time')
        xlabel('Trials')
        text(length(name.sessionNum)-50, 0.45, 'Low', 'color', 'b', 'HorizontalAlignment', 'right')
        text(length(name.sessionNum)-50, 0.55, 'High', 'color', 'r', 'HorizontalAlignment', 'right')



        sig = round(sig/5);
        if sig < 2
            sig == 2;
        end

        trial_reference = 1:length(name.stimulus);
        go = name.lick(1,:) | name.lick(2,:)| name.lick(3,:) | name.lick(4,:);
        easy = name.stimulus == 2 | name.stimulus == 2.828427 | name.stimulus == 22.627417 | name.stimulus == 32;
        hard = name.stimulus == 4.0000 | name.stimulus == 5.65685400000000 | name.stimulus == 11.3137080000000 | name.stimulus ==  16.0000;


        easy_rxn = movsum(name.rxnTime(easy & go), [sig, 0])./sig;
        easy_trials = trial_reference(easy&go);
        hard_rxn = movsum(name.rxnTime(hard & go), [sig, 0])./sig;
        hard_trials = trial_reference(hard&go);
        all_rxn = movsum(name.rxnTime(name.rxnTime > 0 & go), [sig, 0])./sig;
        all_trials = trial_reference(name.rxnTime > 0 & go);

        subplot(4,1,3)
        plot(easy_trials(sig:end), easy_rxn(sig:end), 'b');
        hold on
        plot(hard_trials(sig:end), hard_rxn(sig:end), 'r');
        hold on
        plot(all_trials(sig:end), all_rxn(sig:end), 'k');
        xlim([0 length(name.sessionNum)])
        title('Easy versus Hard versus All')
        ylabel('Reaction Time')
        xlabel('Trials')
        text(50, 800, 'Easy', 'color', 'b', 'HorizontalAlignment', 'left')
        text(50, 830, 'Hard', 'color', 'r', 'HorizontalAlignment', 'left')
        text(50, 860, 'All', 'color', 'k', 'HorizontalAlignment', 'left')
        plot(diff(name.sessionNum)*1000, ':', 'color', [0.5 0.5 0.5])
        ylim([700 max(all_rxn(sig:end))+10])



        high = name.stimulus > 8;
        low = name.stimulus  < 8;
        low_rxn = movsum(name.rxnTime(low & go), [sig, 0])./sig;
        low_trials = trial_reference(low &go);
        high_rxn = movsum(name.rxnTime(high & go), [sig, 0])./sig;
        high_trials = trial_reference(high&go);

        subplot(4,1,4)
        plot(low_trials(sig:end), low_rxn(sig:end), 'b');
        hold on
        plot(high_trials(sig:end), high_rxn(sig:end), 'r');
        xlim([0 length(name.sessionNum)])
        title('Low versus High')
        ylabel('Success Rate')
        xlabel('Trials')
        text(50, 800, 'Low', 'color', 'b', 'HorizontalAlignment', 'left')
        text(50, 830, 'High', 'color', 'r', 'HorizontalAlignment', 'left')
        plot(diff(name.sessionNum)*1000, ':', 'color', [0.5 0.5 0.5])
        ylim([700 max(all_rxn(sig:end))+10])
    else
        for i = 1:2
            figure
            if i == 1
                choose = logical(name.LED);
                sgtitle('LED ON')
            else
                choose = logical(~name.LED);
                sgtitle('LED OFF')
            end
            
            
            subplot(4,1,1)
            [x,y] = get_performance_trajectory(name, 'easy', sig, 'hits', choose);
            plot(x(sig:end),y(sig:end),'b')
            hold on
            [x,y] = get_performance_trajectory(name, 'hard', sig, 'hits', choose);
            plot(x(sig:end),y(sig:end),'r')
            hold on
            [x,y] = get_performance_trajectory(name, 'discriminable', sig, 'hits', choose);
            plot(x(sig:end),y(sig:end),'k')
            plot(diff(name.sessionNum), ':', 'color', [0.5 0.5 0.5])
            xlim([0 length(name.sessionNum)])
            ylim([0.4 1])
            yline(0.85, ':')
            title('Easy verus Hard versus Discriminable')
            ylabel('Success Rate')
            xlabel('Trials')
            text(length(name.sessionNum)-50, 0.45, 'Easy', 'color', 'b', 'HorizontalAlignment', 'right')
            text(length(name.sessionNum)-50, 0.55, 'Hard', 'color', 'r', 'HorizontalAlignment', 'right')
            text(length(name.sessionNum)-50, 0.65, 'Discriminable', 'color', 'k', 'HorizontalAlignment', 'right')


            subplot(4,1,2)
            [x,y] = get_performance_trajectory(name, 'low', sig, 'hits', choose);
            plot(x(sig:end),y(sig:end),'b')
            hold on
            [x,y] = get_performance_trajectory(name, 'high', sig, 'hits', choose);
            plot(x(sig:end),y(sig:end),'r')
            hold on
            plot(diff(name.sessionNum), ':', 'color', [0.5 0.5 0.5])
            xlim([0 length(name.sessionNum)])
            ylim([0.4 1])
            yline(0.85, ':')
            title('Low versus High')
            ylabel('Reaction Time')
            xlabel('Trials')
            text(length(name.sessionNum)-50, 0.45, 'Low', 'color', 'b', 'HorizontalAlignment', 'right')
            text(length(name.sessionNum)-50, 0.55, 'High', 'color', 'r', 'HorizontalAlignment', 'right')



            sig2 = round(sig/5);
            if sig2 < 2
                sig2 = 2;
            end

            trial_reference = 1:length(name.stimulus);
            go = name.rxnTime > 0;
            easy = name.stimulus == 2 | name.stimulus == 2.828427 | name.stimulus == 22.627417 | name.stimulus == 32;
            hard = name.stimulus == 4.0000 | name.stimulus == 5.65685400000000 | name.stimulus == 11.3137080000000 | name.stimulus ==  16.0000;


            easy_rxn = movsum(name.rxnTime(easy & go & choose), [sig2, 0])./sig2;
            easy_trials = trial_reference(easy&go& choose);
            hard_rxn = movsum(name.rxnTime(hard & go& choose), [sig2, 0])./sig2;
            hard_trials = trial_reference(hard&go& choose);
            all_rxn = movsum(name.rxnTime(name.rxnTime > 0 & go& choose), [sig2, 0])./sig2;
            all_trials = trial_reference(name.rxnTime > 0 & go& choose);

            subplot(4,1,3)
            plot(easy_trials(sig2:end), easy_rxn(sig2:end), 'b');
            hold on
            plot(hard_trials(sig2:end), hard_rxn(sig2:end), 'r');
            hold on
            plot(all_trials(sig2:end), all_rxn(sig2:end), 'k');
            xlim([0 length(name.sessionNum)])
            title('Easy versus Hard versus All')
            ylabel('Reaction Time')
            xlabel('Trials')
            text(50, 800, 'Easy', 'color', 'b', 'HorizontalAlignment', 'left')
            text(50, 830, 'Hard', 'color', 'r', 'HorizontalAlignment', 'left')
            text(50, 860, 'All', 'color', 'k', 'HorizontalAlignment', 'left')
            plot(diff(name.sessionNum)*max(all_rxn(sig2:end))+10, ':', 'color', [0.5 0.5 0.5])
            ylim([700 max(all_rxn(sig2:end))+10])



            high = name.stimulus > 8;
            low = name.stimulus  < 8;
            low_rxn = movsum(name.rxnTime(low & go& choose), [sig2, 0])./sig2;
            low_trials = trial_reference(low &go& choose);
            high_rxn = movsum(name.rxnTime(high & go& choose), [sig2, 0])./sig2;
            high_trials = trial_reference(high&go& choose);

            subplot(4,1,4)
            plot(low_trials(sig2:end), low_rxn(sig2:end), 'b');
            hold on
            plot(high_trials(sig2:end), high_rxn(sig2:end), 'r');
            xlim([0 length(name.sessionNum)])
            title('Low versus High')
            ylabel('Success Rate')
            xlabel('Trials')
            text(50, 800, 'Low', 'color', 'b', 'HorizontalAlignment', 'left')
            text(50, 830, 'High', 'color', 'r', 'HorizontalAlignment', 'left')
            plot(diff(name.sessionNum)*max(all_rxn(sig2:end))+10, ':', 'color', [0.5 0.5 0.5])
            ylim([700 max(all_rxn(sig2:end))+10])
                                               
            
            
            
        end
    
    
                
end