% 用Matlab画出该段语音的时域波形、短时平均能量、短时平均幅度、短时过零率、短时过电平率（电平值自己确定）。自行确定短时分析的帧长和帧移。要求：在一张图上用不同的子图画出各个图形，各图形时间轴（以秒（而非样本数）为单位）要对齐，能够提供清音、浊音和无声段各参数的对比

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


% 1. 计算每个短时帧的平均能量和平均幅度。
% 2. 如果平均能量和平均幅度高于阈值，则判定为浊音。
% 3. 对于平均能量和平均幅度低于阈值的帧，计算其短时过零率。
% 4. 如果过零率高于阈值，则判定为清音；否则，判定为无声段。
