% run all automated tests

files = what('test');
for i = 1:length(files.m)
    [~, filename, ~] = fileparts(files.m{i});
    f = str2func(filename);
    success = f();
    if ~success
        error('RR:test_failed', 'Test %s failed.', filename);
    end
end
