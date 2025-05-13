clc;clear;
[y, Fs] = audioread('ex3/task1.wav');

%参数设置
frame_length = 0.02; % 20ms
frame_shift = 0.01;  % 10ms
frame_length_samples = frame_length * Fs;
frame_shift_samples = frame_shift * Fs;
overlap = frame_length_samples - frame_shift_samples;
%短时分析
frames = buffer(y, frame_length_samples, overlap, 'nodelay');
num_frames = size(frames, 2);

frame_silence = frames(:, 8);
frame_voiced = frames(:,104);
frame_unvoiced = frames(:, 230);

target_voice = frame_unvoiced;

P = 20; % LPC阶数

[a,g] = lpc(target_voice,P);
[H_lpc, w_lpc] = freqz(1, a, length(target_voice), Fs);
residual_signal = filter(a, 1, target_voice);

fft_frame = fft(target_voice);
fft_frame = fft_frame(1:length(fft_frame)/2);
freq_axis = linspace(0, Fs/2, length(fft_frame));

time_voiced = (0:length(target_voice)-1) / Fs;

reconstructed_signal = filter(1, a, residual_signal);
% 比较重构信号和原信号
figure;
subplot(3, 1, 1);
plot(time_voiced, target_voice);
xlabel('时间 (秒)');
ylabel('振幅');
title('原始语音帧');
subplot(3, 1, 2);
plot(time_voiced, reconstructed_signal);
xlabel('时间 (秒)');
ylabel('振幅');
title('重构语音帧');
% 比较重构信号和原信号的差异
subplot(3, 1, 3);
plot(time_voiced, target_voice - reconstructed_signal);
xlabel('时间 (秒)');
ylabel('差异');
title('重构信号与原信号的差异');