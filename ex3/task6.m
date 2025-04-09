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

P = 50; % LPC阶数

[a,g] = lpc(target_voice,P);
[H_lpc, w_lpc] = freqz(1, a, length(target_voice), Fs);
residual_signal = filter(a, 1, target_voice);

fft_frame = fft(target_voice);
fft_frame = fft_frame(1:length(fft_frame)/2); 
freq_axis = linspace(0, Fs/2, length(fft_frame));
figure;
subplot(4, 1, 1);
time_voiced = (0:length(target_voice)-1) / Fs;
plot(time_voiced, target_voice);
xlabel('时间 (秒)');ylabel('振幅');title('浊音帧的时域波形');
% 绘制LPC参数频谱
subplot(4,1,2);
plot(w_lpc, P*log10(abs(H_lpc)));hold on;
plot(freq_axis, P*log10(abs(fft_frame)));hold off;
legend('LPC参数谱', '傅立叶频谱');
xlabel('频率 (Hz)');ylabel('幅度 (dB)');title('浊音语音的频谱');
% 绘制傅立叶频谱
subplot(4,1,3);
plot(residual_signal);
xlabel('样本点');ylabel('幅度');title('预测残差信号的波形');

subplot(4,1,4);
fft_residual_signal = fft(residual_signal);
fft_residual_signal = fft_residual_signal(1:length(fft_residual_signal)/2);
freq_axis1 = linspace(0, Fs/2, length(fft_residual_signal));
plot(freq_axis1, P*log10(abs(fft_residual_signal)));
xlabel('频率 (Hz)');ylabel('幅度 (dB)');title('预测残差信号的频谱');