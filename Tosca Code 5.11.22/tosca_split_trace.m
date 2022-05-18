% tosca_split_trace

fn = 'D:\Data\Tosca\KKC94\Session 4\KKC94-Session4-Run2.trace.orig.txt';

s = tosca_read_trace_data(fn);

% copyfile(fn, strrep(fn, '.txt', '.orig.txt'));

data = fileread(fn);

idx = strfind(data, sprintf('%.6f\t1', s(46).Time(1)));

fn = strrep(fn, '.orig.txt', '.txt');

fp = fopen(fn, 'wb');
fwrite(fp, data(1:idx-1));
fclose(fp);

fp = fopen(strrep(fn, 'Run2', 'Run3'), 'wb');
fwrite(fp, ['Time	Event	Message	Data	Source' char(10) data(idx:end)]);
fclose(fp);
