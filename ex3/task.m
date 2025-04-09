clc;clear;
[y, Fs] = audioread('recorded_audio1.wav');

%参数设置
frame_length = 0.02; % 20ms
frame_shift = 0.01;  % 10ms
frame_length_samples = frame_length * Fs;
frame_shift_samples = frame_shift * Fs;
overlap = frame_length_samples - frame_shift_samples;
%短时分析
frames = buffer(y, frame_length_samples, overlap, 'nodelay');
num_frames = size(frames, 2);
time = (0:length(y)-1) / Fs;

%计算短时平均能量
energy = sum(frames.^2) / frame_length_samples;

%计算短时平均幅度
amplitude = mean(abs(frames));

%计算短时过零率
zcr = sum(abs(diff(sign(frames))));

%计算短时过电平率
threshold = 0.006; % 电平阈值
poe = sum(abs(diff(sign(frames-threshold))));
poe = sum(abs(diff(sign(frames+threshold))))+poe;


%绘制图形
figure;
%时域波形
subplot(5,1,1);
plot(time, y);
xlabel('时间 (秒)');
ylabel('振幅');
title('时域波形');

%短时平均能量
subplot(5,1,2);
plot((1:num_frames) * frame_shift, energy);
xlabel('时间 (秒)');
ylabel('能量');
title('短时平均能量');

%短时平均幅度
subplot(5,1,3);
plot((1:num_frames) * frame_shift, amplitude);
xlabel('时间 (秒)');
ylabel('幅度');
title('短时平均幅度');

%短时过零率
subplot(5,1,4);
plot((1:num_frames) * frame_shift, zcr);
xlabel('时间 (秒)');
ylabel('过零率');
title('短时过零率');

%短时过电平率
subplot(5,1,5);
plot((1:num_frames) * frame_shift, poe);
xlabel('时间 (秒)');
ylabel('过电平率');
title('短时过电平率');

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


n = length(frame_voiced);
frame_voiced = frames(:, 35);
frame_unvoiced = frames(:, 329);
autocorr_voiced = xcorr(frame_voiced, 'coeff');
autocorr_unvoiced = xcorr(frame_unvoiced, 'coeff');


cepstrum_voiced = real(ifft(log(abs(fft(frame_voiced)))));
cepstrum_unvoiced = real(ifft(log(abs(fft(frame_unvoiced)))));

cepstrum_voiced = cepstrum_voiced(1:n);
cepstrum_unvoiced = cepstrum_unvoiced(1:n);

autocorr_voiced_positive = autocorr_voiced(n:end); % 从中点开始，取正向部分
autocorr_unvoiced_positive = autocorr_unvoiced(n:end); % 同上


% 绘制倒谱系数图
figure;
subplot(2,1,1);
plot((1:length(autocorr_unvoiced_positive)), cepstrum_voiced);
xlabel('时间点');
ylabel('倒谱系数');
title('清音语音的倒谱系数');

subplot(2,1,2);
plot((1:length(autocorr_unvoiced_positive)), cepstrum_unvoiced);
xlabel('时间点');
ylabel('倒谱系数');
title('浊音语音的倒谱系数');

%绘制自相关函数图
figure;
subplot(2,1,1);
plot((1:length(autocorr_voiced_positive)), autocorr_voiced_positive);
xlabel('时间点');
ylabel('自相关系数');
title('清音语音的自相关函数');

subplot(2,1,2);
plot((1:length(autocorr_unvoiced_positive)), autocorr_unvoiced_positive);
xlabel('时间点');
ylabel('自相关系数');
title('浊音语音的自相关函数');


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

% 
% % 设置参数
% Fs = 8000;          % 采样率为8000Hz
% bits = 16;          % 量化位数为16位
% channels = 1;       % 单通道
% 
% % 创建音频录制器对象
% recObj = audiorecorder(Fs, bits, channels);
% 
% % 开始录制
% disp('开始录音...');
% recordblocking(recObj, 5); % 录制5秒
% 
% % 完成录制
% disp('录音结束.');
% 
% % 获取录音数据
% audioData = getaudiodata(recObj);
% 
% % 保存为.wav文件
% filename = 'recorded_audio1.wav';
% audiowrite(filename, audioData, Fs);
% 
% disp(['录音已保存为 ' filename]);