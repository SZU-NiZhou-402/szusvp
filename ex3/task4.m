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

widewindowLength = 512;%帧长
widewin = hamming(widewindowLength,'periodic');%窗口函数（汉明窗）
wideoverlap = widewindowLength/2; %帧移（一般为帧长的一半）
narrowwindowLength = 64;
narrowwin = hamming(narrowwindowLength,'periodic');
narrowoverlap = narrowwindowLength/2;
figure;
ffTLength = 512; %做DFT的点数，一般和帧长一样
t = (1/Fs) * (0:numel(y)-1);%
subplot(3,1,1);plot(t,y);title('波形图');
subplot(3,1,2);spectrogram(y,widewin,wideoverlap,ffTLength,Fs,'yaxis');title('窄带语谱图')
subplot(3,1,3);spectrogram(y,narrowwin,narrowoverlap,ffTLength,Fs,'yaxis');title('宽带语谱图')

%浊音
[a,g] = lpc(frame_voiced,20);
[H_lpc, w_lpc] = freqz(1, a, length(frame_voiced), Fs);
residual_signal = filter(a, 1, frame_voiced);

fft_frame = fft(frame_voiced);
fft_frame = fft_frame(1:length(fft_frame)/2); 
freq_axis = linspace(0, Fs/2, length(fft_frame));
figure;
subplot(4, 1, 1);
time_voiced = (0:length(frame_voiced)-1) / Fs;
plot(time_voiced, frame_voiced);
xlabel('时间 (秒)');ylabel('振幅');title('浊音帧的时域波形');
% 绘制LPC参数频谱
subplot(4,1,2);
plot(w_lpc, 20*log10(abs(H_lpc)));hold on;
plot(freq_axis, 20*log10(abs(fft_frame)));hold off;
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
plot(freq_axis1, 20*log10(abs(fft_residual_signal)));
xlabel('频率 (Hz)');ylabel('幅度 (dB)');title('预测残差信号的频谱');



reconstructed_signal = filter(1, a, residual_signal);
% 比较重构信号和原信号
figure;
subplot(3, 1, 1);
plot(time_voiced, frame_voiced);
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
plot(time_voiced, frame_voiced - reconstructed_signal);
xlabel('时间 (秒)');
ylabel('差异');
title('重构信号与原信号的差异');