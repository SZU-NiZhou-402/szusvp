% 用Matlab画出该段语音的时域波形、短时平均能量、短时平均幅度、短时过零率、短时过电平率（电平值自己确定）。
% 自行确定短时分析的帧长和帧移。
% 要求：在一张图上用不同的子图画出各个图形，
% 各图形时间轴（以秒（而非样本数）为单位）要对齐，能够提供清音、浊音和无声段各参数的对比。

% 参数设置
[x, fs] = audioread('ex3/task1_a.wav');
frame_length = 256;    % 帧长（样本数）
frame_shift = 128;     % 帧移（样本数）
level_threshold = 0.1; % 电平阈值

% 计算帧数和时间轴
frame_num = floor((length(x) - frame_length) / frame_shift) + 1;
time_axis = ((0:frame_num-1) * frame_shift + frame_length/2) / fs;
time_samples = (0:length(x)-1) / fs;

% 预分配数组
energy = zeros(frame_num, 1);
amplitude = zeros(frame_num, 1);
zero_crossing = zeros(frame_num, 1);
over_level = zeros(frame_num, 1);

% 计算各种短时特征
for i = 1:frame_num
    % 提取当前帧
    start_idx = (i - 1) * frame_shift + 1;
    frame = x(start_idx:start_idx + frame_length - 1);
    
    % 计算特征
    energy(i) = sum(frame .^ 2);
    amplitude(i) = sum(abs(frame));
    zero_crossing(i) = sum(abs(diff(frame > 0))) / frame_length;
    over_level(i) = sum(abs(frame) > level_threshold) / frame_length;
end

% 对语音进行分段（清音、浊音、无声段）
% 设置阈值
energy_threshold = 0.05 * max(energy);  % 能量阈值，用于判断无声段
zcr_threshold = 0.2;                   % 过零率阈值，用于区分清音和浊音

% 分类各帧
segment_type = zeros(frame_num, 1);
for i = 1:frame_num
    if energy(i) < energy_threshold
        segment_type(i) = 0;  % 无声段
    elseif zero_crossing(i) > zcr_threshold
        segment_type(i) = 1;  % 清音
    else
        segment_type(i) = 2;  % 浊音
    end
end

% 创建图形
figure('Position', [100, 100, 800, 800]);

% 绘制所有子图
subplot(5, 1, 1);
plot(time_samples, x);
title('语音波形'); ylabel('幅度'); grid on;
hold on;

% 添加分段背景色
for i = 1:frame_num
    start_time = (i-1) * frame_shift / fs;
    end_time = min((i-1) * frame_shift + frame_length, length(x)) / fs;
    if segment_type(i) == 0  % 无声段
        rectangle('Position', [start_time, -1, end_time-start_time, 2], ...
                 'FaceColor', [0.9, 0.9, 0.9], 'EdgeColor', 'none', 'HandleVisibility', 'off');
    elseif segment_type(i) == 1  % 清音
        rectangle('Position', [start_time, -1, end_time-start_time, 2], ...
                 'FaceColor', [1, 0.8, 0.8], 'EdgeColor', 'none', 'HandleVisibility', 'off');
    else  % 浊音
        rectangle('Position', [start_time, -1, end_time-start_time, 2], ...
                 'FaceColor', [0.8, 0.8, 1], 'EdgeColor', 'none', 'HandleVisibility', 'off');
    end
end
plot(time_samples, x);  % 重新绘制波形，以便显示在背景上方

% 绘制其他子图并添加分段背景
features = {energy, amplitude, zero_crossing, over_level};
titles = {'短时平均能量', '短时平均幅度', '短时过零率', ['短时过电平率 (阈值 = ', num2str(level_threshold), ')']};
ylabels = {'能量', '幅度', '过零率', '过电平率'};

for p = 1:4
    subplot(5, 1, p+1);
    hold on;
    
    % 添加分段背景色
    for i = 1:frame_num
        if segment_type(i) == 0  % 无声段
            line([time_axis(i), time_axis(i)], [0, max(features{p})], 'Color', [0.9, 0.9, 0.9], 'LineWidth', 5, 'HandleVisibility', 'off');
        elseif segment_type(i) == 1  % 清音
            line([time_axis(i), time_axis(i)], [0, max(features{p})], 'Color', [1, 0.8, 0.8], 'LineWidth', 5, 'HandleVisibility', 'off');
        else  % 浊音
            line([time_axis(i), time_axis(i)], [0, max(features{p})], 'Color', [0.8, 0.8, 1], 'LineWidth', 5, 'HandleVisibility', 'off');
        end
    end
    
    plot(time_axis, features{p});
    title(titles{p}); ylabel(ylabels{p}); grid on;
    
    if p == 4  % 最后一个子图添加x轴标签
        xlabel('时间 (秒)');
    end
end

% 设置所有子图的x轴范围一致
for i = 1:5
    subplot(5, 1, i);
    xlim([0, time_samples(end)]);
end

% 添加图例
subplot(5, 1, 1);
h_legend = legend('语音信号', '无声段', '清音段', '浊音段');
set(h_legend, 'Location', 'northeastoutside', 'AutoUpdate', 'off');

% 创建无声段、清音段和浊音段的示例线条（用于图例）
hold on;
plot(NaN, NaN, 'Color', 'k');  % 语音信号
rectangle('Position', [0, 0, 0, 0], 'FaceColor', [0.9, 0.9, 0.9], 'EdgeColor', 'k');  % 无声段
rectangle('Position', [0, 0, 0, 0], 'FaceColor', [1, 0.8, 0.8], 'EdgeColor', 'k');    % 清音段
rectangle('Position', [0, 0, 0, 0], 'FaceColor', [0.8, 0.8, 1], 'EdgeColor', 'k');    % 浊音段

sgtitle('语音信号短时分析（清音、浊音和无声段对比）');
