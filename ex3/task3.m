% 分别选择一帧无声、清音和浊音的语音，用Matlab画出它们的对数幅度谱（语音分析中如无特别，一般“频谱”均指“对数幅度谱”），并简要分析三者频谱的特性和区别（包括基频、共振峰、能量在整个频带的分布等）。
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

frame_silence = frames(:, 300);
frame_voiced = frames(:,35);
frame_unvoiced = frames(:, 329);

%计算对数幅度谱
silence_spec = 20 * log10(abs(fft(frame_silence)));
voiced_spec = 20 * log10(abs(fft(frame_voiced)));
unvoiced_spec = 20 * log10(abs(fft(frame_unvoiced)));

silence_spec = silence_spec(1:length(silence_spec)/2);
voiced_spec = voiced_spec(1:length(voiced_spec)/2);
unvoiced_spec = unvoiced_spec(1:length(unvoiced_spec)/2);

%绘制对数幅度谱
figure;
subplot(3,2,1);
time = (0:length(frame_silence)-1) / Fs;
plot(time, frame_silence);
xlabel('时间 (秒)');
ylabel('振幅');
title('无声时域波形');

subplot(3,2,2);
plot(linspace(0, Fs/2, length(silence_spec)), silence_spec);
xlabel('频率 (Hz)');
ylabel('幅度 (dB)');
title('无声语音的对数幅度谱');


subplot(3,2,3);
time = (0:length(frame_voiced)-1) / Fs;
plot(time, frame_voiced);
xlabel('时间 (秒)');
ylabel('振幅');
title('清音时域波形');

subplot(3,2,4);
plot(linspace(0, Fs/2, length(voiced_spec)), voiced_spec);
xlabel('频率 (Hz)');
ylabel('幅度 (dB)');
title('清音语音的对数幅度谱');

subplot(3,2,5);
time = (0:length(frame_unvoiced)-1) / Fs;
plot(time, frame_unvoiced);
xlabel('时间 (秒)');
ylabel('振幅');
title('浊音时域波形');

subplot(3,2,6);
plot(linspace(0, Fs/2, length(unvoiced_spec)), unvoiced_spec);
xlabel('频率 (Hz)');
ylabel('幅度 (dB)');
title('浊音语音的对数幅度谱');