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