% 分别选择一帧无声、清音和浊音的语音，用Matlab画出它们的对数幅度谱（语音分析中如无特别，一般“频谱”均指“对数幅度谱”），
% 并简要分析三者频谱的特性和区别（包括基频、共振峰、能量在整个频带的分布等）。

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

% 提取一帧无声、清音和浊音
% 添加调试信息
fprintf('无声段帧数: %d\n', sum(segment_type == 0));
fprintf('清音帧数: %d\n', sum(segment_type == 1));
fprintf('浊音帧数: %d\n', sum(segment_type == 2));

% 调整阈值直到找到所有类型的帧
if sum(segment_type == 0) == 0
    energy_threshold = 0.01 * max(energy);  % 降低无声段阈值
    for i = 1:frame_num
        if energy(i) < energy_threshold
            segment_type(i) = 0;  % 无声段
        end
    end
end

if sum(segment_type == 1) == 0 || sum(segment_type == 2) == 0
    % 尝试不同的过零率阈值
    for i = 1:frame_num
        if energy(i) >= energy_threshold
            if zero_crossing(i) > 0.15  % 调整阈值
                segment_type(i) = 1;    % 清音
            else
                segment_type(i) = 2;    % 浊音
            end
        end
    end
end

% 重新查找帧
silent_frame = find(segment_type == 0, 1);
vowel_frame = find(segment_type == 1, 1);
fricative_frame = find(segment_type == 2, 1);

% 确保找到了帧
if isempty(silent_frame), silent_frame = 1; end
if isempty(vowel_frame), vowel_frame = floor(frame_num/3); end
if isempty(fricative_frame), fricative_frame = floor(2*frame_num/3); end

% 转换为样本索引
silent_start = (silent_frame - 1) * frame_shift + 1;
vowel_start = (vowel_frame - 1) * frame_shift + 1;
fricative_start = (fricative_frame - 1) * frame_shift + 1;

% 计算三种帧的对数幅度谱
silent_spec = computeLogMagSpec(x, silent_start, frame_length);
vowel_spec = computeLogMagSpec(x, vowel_start, frame_length);
fricative_spec = computeLogMagSpec(x, fricative_start, frame_length);

% 创建频率轴
freq_axis = (0:frame_length/2) * fs / frame_length;

% 无声段对数幅度谱
subplot(3, 1, 1);
plot(freq_axis, silent_spec);
title('无声段对数幅度谱'); xlabel('频率 (Hz)'); ylabel('幅度 (dB)'); grid on;

% 清音对数幅度谱
subplot(3, 1, 2);
plot(freq_axis, vowel_spec);
title('清音对数幅度谱'); xlabel('频率 (Hz)'); ylabel('幅度 (dB)'); grid on;

% 浊音对数幅度谱
subplot(3, 1, 3);
plot(freq_axis, fricative_spec);
title('浊音对数幅度谱'); xlabel('频率 (Hz)'); ylabel('幅度 (dB)'); grid on;

% 创建计算对数幅度谱的函数，即计算频谱
function log_mag_spec = computeLogMagSpec(signal, frame_idx, frame_length)
    frame = signal(frame_idx:frame_idx + frame_length - 1);
    frame = frame .* hamming(frame_length);
    frame_fft = fft(frame);
    mag_spec = abs(frame_fft(1:frame_length/2+1));
    % 避免对0取对数
    mag_spec(mag_spec < 1e-10) = 1e-10;
    % 转换为dB
    log_mag_spec = 20 * log10(mag_spec);
    % 归一化
    log_mag_spec = log_mag_spec - max(log_mag_spec);
end
