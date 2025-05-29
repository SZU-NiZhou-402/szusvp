% 1、从提供的语音数据中任选一句，在Matlab中读入该语音数据及附带的SUV标注数据（手工标注，默认为标准的标注），画出该语音波形并根据SUV标注数据在该波形图（图1）中标注该段语音的各个SUV片段。

sound_path = "ex4/SUV/F1.wav";
tag_path = "ex4/SUV/F1.txt";

fileID = fopen(tag_path, 'r');
data = textscan(fileID, '%s %f %f');

fclose(fileID);

labels = data{1};      % SUV 标签
start_times = data{2}; % 起始时间
end_times = data{3};   % 结束时间

% 读取音频文件
[x, fs] = audioread(sound_path);
t = (0:length(x)-1)/fs; % 时间轴

% 调用函数生成标注完成的图
plotSUVSegments(labels, start_times, end_times, t, x);
