function [aviFile, aviFrames] = tosca_find_video_frames(TL, TrialNum, StateNum, Pre, Post)

aviFile = TL.trials{TrialNum}.aviFile;

if Pre > 0
   aviFrames = TL.trials{TrialNum}.states(StateNum-1).frames(end-Pre:end);
else
   aviFrames = [];
end

aviFrames = [aviFrames; TL.trials{TrialNum}.states(StateNum).frames(1:Post)];