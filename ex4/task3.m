% 对所有提供的10句语音数据都用步骤2中你所写的程序进行SUV端点检测
% 并以每句语音所附带标注数据为标准计算你的检测算法的下列性能指标

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

target_labels = ['V', 'U', 'S']; % 目标标签

false_alarm_rates = [];
missing_rates = [];

for i = 1:length(target_labels)
    target_label = target_labels(i);

    false_alarm_rates = FalseAlarmRate(labels, start_times, end_times, merged_labels, merged_start_times, merged_end_times, target_labels);
    missing_rates = MissingRate(labels, start_times, end_times, merged_labels, merged_start_times, merged_end_times, target_labels);
    
    disp(['标签 ', target_label, ' 的性能指标:']);
    disp(['  误警率 (False Alarm Rate): ', num2str(false_alarm_rate)]);
    disp(['  漏警率 (Missing Rate): ', num2str(missing_rate)]);
end
