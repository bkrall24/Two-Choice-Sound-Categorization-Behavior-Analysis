function final_pupil = process_pupil(pupil)


    pupil(pupil > 200 | pupil < 10)= nan;
    pupil(isoutlier(pupil, 'movmedian', 60)) = nan;

    % This uses a median smoothing filter with a window of 7 samples - the
    % bigger the window, the smoother the data. 5-10 seems to maintain the
    % shape of smaller pupil changes while still smoothing nicely
    smoothPupil = smoothdata(pupil, 'movmedian', 7);
   
    
    % This next chunk of code interpolates data for nan values. We only
    % want to do this when we have sufficient data points around the nan to
    % interpolate. So this identifies the indices where there is a nan, but
    % it is not contained in a block of 5 or more nans. 
    nanFinder =(isnan(smoothPupil));
    df = diff(nanFinder);
    starts = find(df == 1);
    lasts = find(df == -1);
    
    try
        if lasts(1) < starts(1)
            starts = [0; starts];
        end

        if lasts(end) < starts(end)
            lasts(end+1) = length(smoothPupil);
        end
        starts = starts+1;

        add = [];
        for i = 1:length(starts)
            nanLength = lasts(i) - starts(i);
            if nanLength < 5
                add = [add, (starts(i):lasts(i))];
            end
        end
        nanInd = add';
    catch
        nanInd = [];
    end
    
    
    dataInd = find(~isnan(smoothPupil));
    dataY = smoothPupil(dataInd);

    try
        interpolatedData = spline(dataInd, dataY, nanInd);

        smoothPupil(nanInd) = interpolatedData;
    end
    %finalPupil = (smoothPupil./max(pupil))*100;
    final_pupil = smoothPupil;
     
end