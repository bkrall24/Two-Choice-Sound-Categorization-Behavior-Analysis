function [TL, avi] = tosca_repair_video(TL, avi)

done = false;
while ~done
   aviErrorTrial = -1;
   
   for k = 1:length(avi)
      if avi(k).toscaTime > TL.trials{k}.start + 1
         aviErrorTrial = k-1;
         break;
      end
   end
   
   if aviErrorTrial > 0
      [TL, avi] = repair_one(TL, avi, aviErrorTrial);
   else
      fprintf('Video data successfully repaired.\n');
      done = true;
   end
end

%--------------------------------------------------------------------------
function [TL, avi] = repair_one(TL, avi, aviErrorTrial)

fprintf('Splitting video at trial %d...\n', aviErrorTrial);

% Find length of error trial in Tosca time
dt = TL.trials{aviErrorTrial}.stop - TL.trials{aviErrorTrial}.start;
% Find where in time to break the avi
tLastFrameErrorTrial = avi(aviErrorTrial).states(1).tframe(1) + dt;

fn = TL.filename;
avilogPath = strrep(fn, '.txt', '.avi.log');

% Read the avi log as text
fp = fopen(avilogPath, 'rt');
data = textscan(fp, '%f\t%f\t%f\t%s');
fclose(fp);

% Find where to insert the new trial (marked by 'File:.xyz') into the log
tvideo = data{2};
[~, ilast] = min(abs(tvideo - tLastFrameErrorTrial));

% The .avi files following the break will have their file numbers
% incremented by one. Modify log accordingly.
for k = 1:length(data{4})
   n = sscanf(data{4}{k}, 'File:.%03d');
   if ~isempty(n) && n > aviErrorTrial
      data{4}{k} = sprintf('File:.%03d', n+1);
   end
end

% Find first frame after the break (i.e. the start of the Tosca trial).
% [data{3} = frame number]
firstframeNextTrial = data{3}(ilast+1);

% Insert missing Trial and File lines to .avi log
data{1} = [data{1}(1:ilast); -1; -1; data{1}(ilast+1:end)];
data{2} = [data{2}(1:ilast); data{2}(ilast+1); data{2}(ilast+1); data{2}(ilast+1:end)];
data{3} = [data{3}(1:ilast); -1; -1; data{3}(ilast+1:end)];
data{4} = [data{4}(1:ilast); {sprintf('Trial:%f', TL.trials{aviErrorTrial+1}.start)}; {sprintf('File:%03d', aviErrorTrial+1)}; data{4}(ilast+1:end)];

% Adjust frame numbers for newly inserted file
iNextNext = find(strcmp(data{4}, sprintf('File:%03d', aviErrorTrial+2)));
for k = ilast:iNextNext
   if data{3}(k) > 0
      data{3}(k) = data{3}(k) - firstframeNextTrial;
   end
end

% Make a backup of the log
copyfile(avilogPath, [avilogPath '.backup']);

% Save the modified log
fp = fopen(avilogPath, 'wt');
for k = 1:length(data{1})
   fprintf(fp, '%d\t%f\t%d\t%s\n', data{1}(k), data{2}(k), data{3}(k), data{4}{k});
end
fclose(fp);


%% Renumber video files after the break
[folder, filestem] = fileparts(fn);
aviList = dir(fullfile(folder, sprintf('%s.*.avi', filestem)));
nmax = -1;
for k = 1:length(aviList)
   n = sscanf(aviList(k).name, [filestem '.%03d.avi']);
   nmax = max(nmax, n);
end

for k = nmax:-1:aviErrorTrial+1
   movefile(sprintf('%s.%03d.avi', filestem, k), sprintf('%s.%03d.avi', filestem, k+1));
end

%% Split the video
fnPre = sprintf('%s.%03d.avi', filestem, aviErrorTrial);
fnPost = sprintf('%s.%03d.avi', filestem, aviErrorTrial+1);

copyfile(fnPre, [fnPre '.backup']);

vidPrebig = VideoReader([fnPre '.backup']);
vidPre = VideoWriter(fnPre);
vidPre.Quality = 80;

open(vidPre);
for k = 1 : firstframeNextTrial - 1
   thisFrame = read(vidPrebig, k);
   writeVideo(vidPre, thisFrame);
end

close(vidPre);

vidPost = VideoWriter(fnPost);
vidPost.Quality = 80;

open(vidPost);
for k = firstframeNextTrial : vidPrebig.NumFrames
   thisFrame = read(vidPrebig, k);

   writeVideo(vidPost, thisFrame);
end

close(vidPost);

delete(vidPrebig);

avi = tosca_read_avi_log(avilogPath);
