% % 录音
% % 8kHz
% recObj = audiorecorder(8000,16,1);
% disp('Start speaking.')
% recordblocking(recObj, 5);
% disp('End of Recording.');
% y1 = getaudiodata(recObj);
% audiowrite('ex1/8k.wav',y1,8000);

% % 16kHz
% recObj = audiorecorder(16000,16,1);
% disp('Start speaking.')
% recordblocking(recObj, 5);
% disp('End of Recording.');
% y2 = getaudiodata(recObj);
% audiowrite('ex1/16k.wav',y2,16000);

% % 44.1kHz
% recObj = audiorecorder(44100,16,1);
% disp('Start speaking.')
% recordblocking(recObj, 5);
% disp('End of Recording.');
% y3 = getaudiodata(recObj);
% audiowrite('ex1/44.1k.wav',y3,44100);

% 1、语音录制与播放。使用任意工具录制一段语音。录音内容：任意句子，时长3-5秒，句长5-10个汉字；录三遍，采样率分别为8kHz,16kHz,44.1kHz（或48kHz,依录音工具不同采样率可能不同）;重放三居语音，感受音质的区别。

% % 8kHz
% [y1,fs1] = audioread('ex1/8k.wav');
% sound(y1,fs1);
% pause(5);
% % 16kHz
% [y2,fs2] = audioread('ex1/16k.wav');
% sound(y2,fs2);
% pause(5);
% % 44.1kHz
% [y3,fs3] = audioread('ex1/44.1k.wav');
% sound(y3,fs3);
% pause(5);

% 2、利用音频工具将所录制的语音以图形（包括时域与频域图形）显示，通过对比语音的听觉感知和视觉感知进一步加深对语音的认知；

% % 8kHz
% subplot(3,2,1);
% plot(y1);
% title('8kHz Time Domain');
% subplot(3,2,2);
% spectrogram(y1,256,250,256,fs1,'yaxis');
% title('8kHz Frequency Domain');

% % 16kHz
% subplot(3,2,3);
% plot(y2);
% title('16kHz Time Domain');
% subplot(3,2,4);
% spectrogram(y2,256,250,256,fs2,'yaxis');
% title('16kHz Frequency Domain');

% % 44.1kHz
% subplot(3,2,5);
% plot(y3);
% title('44.1kHz Time Domain');
% subplot(3,2,6);
% spectrogram(y3,256,250,256,fs3,'yaxis');
% title('44.1kHz Frequency Domain');

% 3、检查你所录制音频的格式，其采样率、每样本量化比特分别是多少？计算所录制语音的数码率（bit per second, bps）。

% % 8kHz
% info1 = audioinfo('ex1/8k.wav');
% disp(['8kHz Sample Rate: ',num2str(info1.SampleRate)]);
% disp(['8kHz Bits Per Sample: ',num2str(info1.BitsPerSample)]);
% disp(['8kHz Bit Rate: ',num2str(info1.TotalSamples*info1.BitsPerSample*info1.NumChannels/info1.Duration)]);

% % 16kHz
% info2 = audioinfo('ex1/16k.wav');
% disp(['16kHz Sample Rate: ',num2str(info2.SampleRate)]);
% disp(['16kHz Bits Per Sample: ',num2str(info2.BitsPerSample)]);
% disp(['16kHz Bit Rate: ',num2str(info2.TotalSamples*info2.BitsPerSample*info2.NumChannels/info2.Duration)]);

% % 44.1kHz
% info3 = audioinfo('ex1/44.1k.wav');
% disp(['44.1kHz Sample Rate: ',num2str(info3.SampleRate)]);
% disp(['44.1kHz Bits Per Sample: ',num2str(info3.BitsPerSample)]);
% disp(['44.1kHz Bit Rate: ',num2str(info3.TotalSamples*info3.BitsPerSample*info3.NumChannels/info3.Duration)]);

% 4、针对你所录制的16kHz采样率的语音，将其降采样到8kHz,比较三个音频（16kHz采样录制、8kHz降采样、8kHz采样录制）的区别（听觉感知、视觉感知）

% % 16kHz
% [y2,fs2] = audioread('ex1/16k.wav');
% sound(y2,fs2);
% pause(5);

% % 降采样到8kHz
% new_fs = 8000;  % 目标采样率
% [y2_8k,fs2_8k] = resample(y2,new_fs,fs2);
% sound(y2_8k,new_fs);  % 使用目标采样率播放
% pause(5);

% % 8kHz
% [y1,fs1] = audioread('ex1/8k.wav');
% sound(y1,fs1);
% pause(5);

% % 可视化比较
% figure;
% subplot(3,1,1);
% plot(y2); title('16kHz原始信号');
% subplot(3,1,2);
% plot(y2_8k); title('降采样到8kHz的信号');
% subplot(3,1,3);
% plot(y1); title('8kHz原始录制信号');

% 5、针对你所录制的8kHz采样率的语音，将其升采样到16kHz,比较三个音频（8kHz采样录制、16kHz升采样、16kHz采样录制）的区别（听觉感知、视觉感知）

% % 8kHz
% [y1,fs1] = audioread('ex1/8k.wav');
% sound(y1,fs1);
% pause(5);

% % 升采样到16kHz
% new_fs = 16000;  % 目标采样率
% [y1_16k,fs1_16k] = resample(y1,new_fs,fs1);
% sound(y1_16k,new_fs);  % 使用目标采样率播放
% pause(5);

% % 16kHz
% [y2,fs2] = audioread('ex1/16k.wav');
% sound(y2,fs2);
% pause(5);

% % 可视化比较
% figure;
% subplot(3,1,1);
% plot(y1); title('8kHz原始信号');
% subplot(3,1,2);
% plot(y1_16k); title('升采样到16kHz的信号');
% subplot(3,1,3);
% plot(y2); title('16kHz原始录制信号');

% 6、原始录制的音频数据其量化比特率一般是16 bit per sample，即每个样本占用2个字节。改变所录制语音的量化比特数（例如12、8比特），比较不同量化精度下的语音质量和数码率。

% % 16 bit
% [y,fs] = audioread('ex1/16k.wav');
% sound(y,fs);
% pause(5);

% % 12 bit
% y_12 = y;
% y_12 = y_12*2^4;  % 16bit转12bit
% y_12 = round(y_12);  % 四舍五入
% y_12 = y_12/2^4;  % 12bit转回16bit
% sound(y_12,fs);
% pause(5);

% % 8 bit
% y_8 = y;
% y_8 = y_8*2^8;  % 16bit转8bit
% y_8 = round(y_8);  % 四舍五入
% y_8 = y_8/2^8;  % 8bit转回16bit
% sound(y_8,fs);
% pause(5);

% % 可视化比较
% figure;
% subplot(3,1,1);
% plot(y); title('16bit原始信号');
% subplot(3,1,2);
% plot(y_12); title('12bit量化信号');
% subplot(3,1,3);
% plot(y_8); title('8bit量化信号');

% % 7、在所录制的语音中分别定位出一段属于“乐音”和“噪音”的片段，观察它们的波形和频谱有何不同？在不同采样率和量化比特数时波形和频谱有何不同？

% % 16kHz
% disp('原声')
% [y,fs] = audioread('ex1/16k.wav');
% sound(y,fs);
% pause(5);

% Fc = 2000; % 截止频率
% [b, a] = butter(6, Fc/(fs/2), 'low');
% y_music = filtfilt(b, a, y); % 乐音部分
% y_noise = y - y_music;         % 残留为噪音

% disp('乐音')
% sound(y_music,fs);
% pause(5);

% disp('噪音')
% sound(y_noise,fs);
% pause(5);

% % 可视化比较
% figure;
% subplot(2,2,1);
% plot(y_music); title('乐音波形');
% subplot(2,2,2);
% spectrogram(y_music,256,250,256,fs,'yaxis'); title('乐音频谱');
% subplot(2,2,3);
% plot(y_noise); title('噪音波形');
% subplot(2,2,4);
% spectrogram(y_noise,256,250,256,fs,'yaxis'); title('噪音频谱');

% 8、针对前面所录16kHz采样、16bit 量化的语音，写一段代码，将该语音的量化比特改为8,6,4，2比特，计算各个低量化版本的新语音相对于原始语音的信噪比，从中推定信噪比和量化比特数。

% 16kHz
[y,fs] = audioread('ex1/16k.wav');
% sound(y,fs);
% pause(5);

% 量化函数
function y_ = quantize(y,bit)
    y_ = y;
    y_ = y_*2^bit;  % 16bit转bit
    y_ = round(y_);  % 四舍五入
    y_ = y_/2^bit;  % bit转回16bit
end

% 计算信噪比
function snr_ = snr(y,y_)
    snr_ = 10*log10(sum(y.^2)/sum((y-y_).^2));
end

bits = [8 6 4 2];  
y_quantized = cell(length(bits), 1);
snr_values = zeros(length(bits), 1);

disp(['16bit信噪比: ',num2str(snr(y,y))]);

for i = 1:length(bits)
    y_quantized{i} = quantize(y, bits(i));
    snr_values(i) = snr(y, y_quantized{i});
    disp([num2str(bits(i)),'bit信噪比: ',num2str(snr_values(i))]);
end
