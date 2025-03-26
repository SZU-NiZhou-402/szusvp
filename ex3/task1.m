% 以正常语速说话，录一段长约3-5秒的语音信号。要求：必须为本人的语音；采样率为8000Hz, 16bit量化，单通道，若不是，用Matlab将其转化为符合要求；在较为安静的环境下录音；音量适中（波形最大值在0.7左右）；


% 读取音频文件
[x, fs] = audioread('ex3/task1.m4a');

% 如果是多通道，只保留第一个通道
if size(x, 2) > 1
    x = x(:, 1); % 只保留第一个通道
end

% 重采样
x = resample(x, 8000, fs);
fs = 8000;

% 归一化音量，使最大值为0.7
max_val = max(abs(x)); % 现在是标量
scale_factor = 0.7 / max_val;
x = x * scale_factor;

% 量化为16位整数
x = x * 32767; % 缩放到16位范围 (-32768 到 32767)
x = int16(x); % 转换为16位整数

% 保存音频文件
audiowrite('ex3/task1_a.wav', double(x)/32767, fs); % 转回浮点数保存
