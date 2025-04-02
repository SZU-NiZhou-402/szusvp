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

frame_voiced = frames(:,64);
frame_unvoiced = frames(:, 230);
n = length(frame_voiced);
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