close all; clear all; 

info=audioinfo('F1.wav')  %这里F1.wav就放在当前目录下，如不是，需要给出正确的文件路径
[x,fs]=audioread('F1.wav');
x_downSamp_half=resample(x,1,2);
audiowrite('F1_half.wav',x_downSamp_half,fs/2);
x_downSamp_quart=resample(x,1,4);
audiowrite('F1_quart.wav',x_downSamp_quart,fs/4);
x_upSamp_double=resample(x,2,1);
audiowrite('F1_double.wav',x_upSamp_double,fs*2);
info=audioinfo('F1_half.wav')
info=audioinfo('F1_quart.wav')
info=audioinfo('F1_double.wav')
sound(x,fs); pause
% sound(x_downSamp_half,fs/2); pause
% sound(x_downSamp_quart,fs/4); pause
% sound(x_upSamp_double,fs*2); pause
%可以把以上这些注释去掉，听听声音有何区别？

figure(1);
subplot(421);plot([1:length(x)]/fs,x);xlabel('时间(s)');ylabel('幅度');
subplot(422);pwelch(x,hamming(256),128,256,fs);
subplot(423);plot([1:length(x_downSamp_half)]/(fs/2),x_downSamp_half);xlabel('时间(s)');ylabel('幅度');
subplot(424);pwelch(x_downSamp_half,hamming(256),128,256,fs/2);
subplot(425);plot([1:length(x_downSamp_quart)]/(fs/4),x_downSamp_quart);xlabel('时间(s)');ylabel('幅度');
subplot(426);pwelch(x_downSamp_quart,hamming(256),128,256,fs/4);
subplot(427);plot([1:length(x_upSamp_double)]/(fs*2),x_upSamp_double);xlabel('时间(s)');ylabel('幅度');
subplot(428);pwelch(x_upSamp_double,hamming(256),128,256,fs*2);
% 以上是画出整段语音的波形和频谱；尝试自己实现画其中一段浊音（或清音）的波形和频谱

[b,a]=butter(6,0.5,'low');
%freqz(b,a,fs)
x_LPF_half=filter(b,a,x);
[b1,a1]=butter(6,0.25,'low');
x_LPF_quart=filter(b1,a1,x);
[b2,a2]=butter(6,0.125,'low');
x_LPF_oct=filter(b2,a2,x);
%掌握滤波器设计的MATLAB实现，以上只是其中一个例子，更多细节可以自己再深入学习摸索

figure(2)
subplot(431);plot([1:length(x)]/fs,x);xlabel('时间(s)');ylabel('幅度');
subplot(432);pwelch(x,hamming(256),128,256,fs);
subplot(433); spectrogram(x,hamming(256),128,256,fs,'yaxis');
subplot(434);plot([1:length(x_LPF_half)]/fs,x_LPF_half);xlabel('时间(s)');ylabel('幅度');
subplot(435);pwelch(x_LPF_half,hamming(256),128,256,fs);
subplot(436); spectrogram(x_LPF_half,hamming(256),128,256,fs,'yaxis')
subplot(437);plot([1:length(x_LPF_quart)]/fs,x_LPF_quart);xlabel('时间(s)');ylabel('幅度');
subplot(438);pwelch(x_LPF_quart,hamming(256),128,256,fs);
subplot(439); spectrogram(x_LPF_quart,hamming(256),128,256,fs,'yaxis');
subplot(4,3,10);plot([1:length(x_LPF_oct)]/fs,x_LPF_oct);xlabel('时间(s)');ylabel('幅度');
subplot(4,3,11);pwelch(x_LPF_oct,hamming(256),128,256,fs);
subplot(4,3,12); spectrogram(x_LPF_oct,hamming(256),128,256,fs,'yaxis');
%尝试改变以上各命令中的不同参数，看看结果有何不同？