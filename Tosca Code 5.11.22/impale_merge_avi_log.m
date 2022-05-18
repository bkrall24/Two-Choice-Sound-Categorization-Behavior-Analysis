function impale_merge_avi_log(FN, varargin)

[folder, filestem] = fileparts(FN);

options.aviFolder = folder;

options = parse_argin_to_struct(options, varargin{:});

% Compile .avi.txt logs
logList = dir(fullfile(options.aviFolder, sprintf('%s*.avi.txt', filestem)));

if isempty(logList)
   error('No .avi.txt files found.');
end

aviLog = struct('fileNum', [], 'frameNum', [], 'time', []);
for k = 1:length(logList)
   m = regexp(logList(k).name, '\.([\d]+)\.avi.txt', 'tokens');
   num = str2double(m{1}{1});
   
   fp = fopen(fullfile(options.aviFolder, logList(k).name), 'rt');
   data = textscan(fp, '%f\t%f\t%f\t%f\t%f');
   fclose(fp);

   trNum = data{2};
   t = data{3};
   frNum = data{5};
   
   itr = find(trNum < 0);
   frNum(itr) = trNum(itr);
   
   aviLog.fileNum = [aviLog.fileNum; num * ones(size(t))];
   aviLog.frameNum = [aviLog.frameNum; frNum];
   aviLog.time = [aviLog.time; t];
end

% Read SCL from Impale data file
load(FN, 'SCL');

% Add video info to SCL array
istart = find(aviLog.frameNum == -1);
for k = 1:length(SCL)
   iend = find(aviLog.frameNum == -(k+1));
   
   if isempty(iend)
      fprintf('Fewer video trials than Impale trials.\n');
      break;
   end

   ifilt = (istart+1) : (iend-1);
   SCL(k).aviNum = aviLog.fileNum(ifilt);
   SCL(k).frameNum = aviLog.frameNum(ifilt);
   SCL(k).frameTime = aviLog.time(ifilt) - aviLog.time(istart);
   
   istart = iend;
end

% Save SCL back into Impale data file
save(FN, 'SCL', '-append');

%--------------------------------------------------------------------------
function [opt, unparsed] = parse_argin_to_struct(opt, varargin)

unparsed = {};

k = 1;
while k <= length(varargin)
   if ischar(varargin{k}) && isfield(opt, varargin{k}) && k<nargin
      opt.(varargin{k}) = varargin{k+1};
      k = k + 2;
   else
      unparsed{end+1} = varargin{k};
      k = k + 1;
   end
end

%--------------------------------------------------------------------------
% END OF IMPALE_MERGE_AVI_LOG.M
%--------------------------------------------------------------------------
