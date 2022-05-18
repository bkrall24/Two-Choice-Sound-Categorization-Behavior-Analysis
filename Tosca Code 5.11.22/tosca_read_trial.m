function [S, FN] = tosca_read_trial(Params, Data, Trial)
% TOSCA_READ_TRIAL -- read detailed data for a single Tosca trial.
% Usage: S = tosca_read_trial(Params, Data)
% 
% Inputs:
%   Params, Data : structures returned by TOSCA_READ_RUN
%   Trial        : trial number
%
% Output:
%   S : structure containing trial data.
%

if ~isfield(Data{Trial}, 'N')
   Data{Trial}.N = Trial;
end

if isnan(Data{Trial}.N)
   % Immediate error, no data for this trial
   S = [];
   return;
end

% Construct trial data filename
[folder, fn] = fileparts(Params.Info.Filename);
fn = fullfile(folder, sprintf('%s-Trial%02d.di.txt', fn, Data{Trial}.N));
if ~exist(fn, 'file')
   if any(strcmpi(Data{Trial}.History,'abort'))
      S = [];
      return;
   else
      error('File does not exist: %s', fn);
   end
end

% fp = fopen(fn, 'rt');

% Parse header row
s = fileread(fn);
isplit = regexp(s, '\n', 'once');


% s = fgetl(fp);
c = textscan(s(1:isplit), '%s', 'delimiter', '\t');
names = c{1};
for k = 1:length(names)
   names{k} = strrep(names{k}, ' ', '_');
   names{k} = strrep(names{k}, '(', '');
   names{k} = strrep(names{k}, ')', '');
end

c = textscan(s(isplit+1:end), '%f', 'delimiter', '\t');
% c = textscan(fp, '%f', 'delimiter', '\t');
% fclose(fp);

nc = length(names);
nr = length(c{1})/nc;

if nr ~= round(nr)
   disp('removing double tabs');
   s = regexprep(s, '\t\t', '\t');
   c = textscan(s(isplit+1:end), '%f', 'delimiter', '\t');
end

nr = floor(length(c{1})/nc);
c{1} = c{1}(1:nr*nc);

val = reshape(c{1}, nc, nr);
val = val';

if Trial <= length(Data)
   S = Data{Trial};
else
end
S.DigitalNames = names;
[~, S.name] = fileparts(fn);

S.name = strrep(S.name, '.di', '');
if isfield(S, 'Track')
   S.name = regexprep(S.name, '-Trial[\d]+', sprintf(': Track %d Trial %d', S.block, S.trial));
elseif isfield(S, 'block')
   S.name = regexprep(S.name, '-Trial[\d]+', sprintf(': Block %d Trial %d', S.block, S.trial));
end

if ~isfield(Params, 'Tosca')
   S.frameSize = 1 / Params.DAQ.Poll_Rate_Hz;
else
   S.frameSize = 1 / Params.Tosca.DAQ.Poll_Rate_Hz;
end

for k = 1:length(names)
   S.(names{k}) = val(:, k)';
end

if nargout > 1
   FN = fn;
end

