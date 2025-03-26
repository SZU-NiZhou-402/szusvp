% 打印44.1k.wav的波形图，横坐标为时间，纵坐标为幅度

[y,fs] = audioread('ex2/44.1k.wav');

% 显示
figure;
plot(y); 
xlabel('Time');
ylabel('Amplitude');

% 显示频率(db)时间波形图
figure;
spectrogram(y,256,250,256,fs,'yaxis');
xlabel('Time');
ylabel('Frequency(db)');
title('44.1kHz Frequency Domain');
