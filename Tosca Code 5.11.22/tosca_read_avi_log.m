function AVI = tosca_read_avi_log(logPath)
% TOSCA_READ_AVI_LOG -- parse .avi.log files into trial-based structure
% Usage: AVI = tosca_read_avi_log(logPath)
%
% --- Inputs ---
% logPath : path to .avi.log file
%

fp = fopen(logPath, 'rt');
data = textscan(fp, '%f\t%f\t%f\t%s');
fclose(fp);

overallFrameNum = data{1};
events = data{4};

trialIndices = find(contains(events, 'Trial'));
trialIndices(end+1) = length(events) + 1;

AVI = struct('aviFile', {}, 'toscaTime', {}, 'states', {});

for k = 1:length(trialIndices)-1
   AVI(k).aviFile = strrep(logPath, '.avi.log', sprintf('.%03d.avi', k));
   AVI(k).toscaTime = sscanf(events{trialIndices(k)}, 'Trial:%f');

   index = trialIndices(k) : trialIndices(k+1)-1;
   trialEvents = events(index);
   tframeLocal = data{2}(index);
   frameInAVI = data{3}(index);

   AVI(k).frameRate = 1 / mean(diff(tframeLocal(frameInAVI > 0)));
   
   S = struct('toscaTime', {}, 'tframe', {}, 'frameNum', {});

   stateIndices = [1; find(contains(trialEvents, 'State:')); length(trialEvents)+1];
   for ks = 1:length(stateIndices)-1
      if ks == 1
         S(ks).toscaTime = AVI(k).toscaTime;
      else
         S(ks).toscaTime = sscanf(trialEvents{stateIndices(ks)}, 'State:%f');
      end
      
      istate = stateIndices(ks) : stateIndices(ks+1)-1;
      tfr = tframeLocal(istate);
      frnum = frameInAVI(istate);
      
      S(ks).tframe = tfr(frnum >= 0);
      S(ks).frameNum = frnum(frnum >= 0);
   end
   
   AVI(k).states = S;
end



return;

frameInAVI = [];
fileNum = [];
tframe = [];

trTime = [];
trNum = [];
firstFrameInTrial = [];
overallFrameNum = [];
n0 = -1;

   vidFile = fullfile(folder, strrep(avilist(k).name, '.txt', ''));
   vid = VideoReader(vidFile);

   n = data{2};
   if k == 1, n0 = n(1); end
   
   frameInAVI = [frameInAVI; (1:vid.NumFrames)'];
   fileNum = [fileNum; (k-1) * ones(vid.NumFrames, 1)];
   overallFrameNum = [overallFrameNum; n(n>0) - n0 + 1];
   
   t = data{3};

   npad = [n; max(n(n>0))+1];
   itr = find(n < 0);
   firstFrameInTrial = [firstFrameInTrial; npad(itr+1)-n0 + 1];
   
   % Tosca trials indicated by n < 0. Corresponding time stamps are on the
   % Tosca clock. Make the trial time the next frame immediately following.
%    trTime = [trTime; t(find(n < 0) + 1)];
%    
%    % Tosca trial number is the absolute value of 'n'
%    trNum = [trNum; abs(n(n<0))];
%    
%    % actual frame times
    ft = t(n > 0); 
%    
%    nfr = sum(n > 0);
%    if nfr ~= vid.NumFrames
%       % There is a bug where the .avi.txt file stops accumulating before
%       % the .avi file fills up. Fill in the missing data here
%       fprintf('%s: number of frames in .avi does not match log file.\n', avilist(k).name); 
%       
%       nadd = vid.NumFrames - nfr;
%       dt = mean(diff(ft)); % mean frame rate, computed from existing frames
%       ft = [ft; ft(end) + ((1:nadd)')*dt];
%    end
    tframe = [tframe; ft];

firstFrameInTrial = [firstFrameInTrial; overallFrameNum(end)+1];
for k = 1:length(firstFrameInTrial)-1
%    AVI(k).start = trTime(k);
%    AVI(k).stop = trTime(k+1);
%    
%    idx = tframe >= trTime(k) & tframe < trTime(k+1);
   idx = overallFrameNum >= firstFrameInTrial(k) & overallFrameNum < firstFrameInTrial(k+1);
   
   AVI(k).frameInAVI = frameInAVI(idx);
   AVI(k).aviNum = fileNum(idx);
   AVI(k).frames = overallFrameNum(idx);
    AVI(k).tframe = tframe(idx);
end
