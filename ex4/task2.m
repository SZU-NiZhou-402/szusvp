% 2、写一段Matlab程序实现基于双门限法（自行决定采用具体哪种方法）的SUV端点检测，
% 并用该程序对步骤1中的语音数据进行检测。
% 根据你的标注结果在图1上添加标注你的SUV检测片段，
% 并与标准标注的结果比较。分析你的标注结果与标准结果的异同点。

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

[merged_labels, merged_start_times, merged_end_times] = getSUVSegments(x, fs);

% 显示合并后的结果
disp("合并后的检测结果：");
disp(table(merged_labels, merged_start_times, merged_end_times));

plotSUVSegments(merged_labels, merged_start_times, merged_end_times, t, x);
