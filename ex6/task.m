clc;clear;
list = ["ex4/SUV/F1.wav"; "ex4/SUV/F2.wav"; "ex4/SUV/F3.wav"; "ex4/SUV/F4.wav";"ex4/SUV/F5.wav"; "ex4/SUV/M1.wav";"ex4/SUV/M2.wav";"ex4/SUV/M3.wav";"ex4/SUV/M4.wav";"ex4/SUV/M5.wav"];
db_values = [-10, -5, 0, 5, 10, 20];
snrwhite_value = zeros(10,length(db_values), 1);snrwhite_value1 = zeros(10,length(db_values), 1);snrwhite_value2 = zeros(10,length(db_values), 1);
pesqwhite_value = zeros(10,length(db_values), 1);pesqwhite_value1 = zeros(10,length(db_values), 1);pesqwhite_value2 = zeros(10,length(db_values), 1);
stoiwhite_value = zeros(10,length(db_values), 1);stoiwhite_value1 = zeros(10,length(db_values), 1);stoiwhite_value2 = zeros(10,length(db_values), 1);
snrpink_value = zeros(10,length(db_values), 1);snrpink_value1 = zeros(10,length(db_values), 1);snrpink_value2 = zeros(10,length(db_values), 1);
pesqpink_value = zeros(10,length(db_values), 1);pesqpink_value1 = zeros(10,length(db_values), 1);pesqpink_value2 = zeros(10,length(db_values), 1);
stoipink_value = zeros(10,length(db_values), 1);stoipink_value1 = zeros(10,length(db_values), 1);stoipink_value2 = zeros(10,length(db_values), 1);
snrpeople_value = zeros(10,length(db_values), 1);snrpeople_value1 = zeros(10,length(db_values), 1);snrpeople_value2 = zeros(10,length(db_values), 1);
pesqpeople_value = zeros(10,length(db_values), 1);pesqpeople_value1 = zeros(10,length(db_values), 1);pesqpeople_value2 = zeros(10,length(db_values), 1);
stoipeople_value = zeros(10,length(db_values), 1);stoipeople_value1 = zeros(10,length(db_values), 1);stoipeople_value2 = zeros(10,length(db_values), 1);
snrnoise_value = zeros(10,length(db_values), 1);pesqnoise_value = zeros(10,length(db_values), 1);stoinoise_value = zeros(10,length(db_values), 1);
snrnoise_value1 = zeros(10,length(db_values), 1);pesqnoise_value1 = zeros(10,length(db_values), 1);stoinoise_value1 = zeros(10,length(db_values), 1);
snrnoise_value2 = zeros(10,length(db_values), 1);pesqnoise_value2 = zeros(10,length(db_values), 1);stoinoise_value2 = zeros(10,length(db_values), 1);
for j = 1:10
    j
    [audio, Fs] = audioread(list(j,:)); %读取音频

    [noiseaudio, noiseFs] = audioread('ex6/noise.m4a'); %读取音频
    
    noiseaudio = resample(noiseaudio, Fs, noiseFs);
    noiseaudio = noiseaudio(3000:length(audio)+3000-1, 1);
    noisePower1 = mean(noiseaudio.^2);
    
    signalPower = mean(audio.^2);  % 计算音频的平均能量
    whiteNoise = randn(size(audio)); %白噪声
    whiteNoise = whiteNoise/std(whiteNoise);
    
    pinkNoise = generatePinkNoise(audio);
    pinkNoisePower = mean(pinkNoise.^2);
    
    
    whiteNoiseaudio = zeros(length(db_values), length(audio));
    pinkNoiseaudio = zeros(length(db_values), length(audio));
    peopleNoiseaudio = zeros(length(db_values), length(audio));
    cleanwhiteaudio = zeros(length(db_values), length(audio));cleanwhiteaudio1 = zeros(length(db_values), length(audio));cleanwhiteaudio2 = zeros(length(db_values), length(audio));
    cleanpinkaudio = zeros(length(db_values), length(audio));cleanpinkaudio1 = zeros(length(db_values), length(audio));cleanpinkaudio2 = zeros(length(db_values), length(audio));
    cleanpeopleaudio = zeros(length(db_values), length(audio));cleanpeopleaudio1 = zeros(length(db_values), length(audio));cleanpeopleaudio2 = zeros(length(db_values), length(audio));
   
    
    for i = 1:length(db_values)
        noisePower = signalPower / (10^(db_values(i) / 10));
        scalingFactor = sqrt(signalPower / pinkNoisePower / 10^(db_values(i)/10));
        noiseFactor = sqrt(signalPower / noisePower1 / 10^(db_values(i)/10));
        
        whiteNoiseScale = sqrt(noisePower) * whiteNoise;
        noiseScale = noiseaudio*noiseFactor;
        pinkNoiseScaled = pinkNoise * scalingFactor;
        
        whiteNoiseaudio(i,:) = whiteNoiseScale+audio;
        pinkNoiseaudio(i,:) = pinkNoiseScaled+audio;
        peopleNoiseaudio(i,:) = noiseScale+audio;
        snrnoise_value(j,i) = snr(audio, whiteNoiseScale);snrnoise_value1(j,i) = snr(audio, pinkNoiseScaled);snrnoise_value2(j,i) = snr(audio, noiseScale);
        pesqnoise_value(j,i) = pesq(audio, whiteNoiseaudio(i,:)', Fs);pesqnoise_value1(j,i) = pesq(audio, pinkNoiseaudio(i,:)', Fs);pesqnoise_value2(j,i) = pesq(audio, peopleNoiseaudio(i,:)', Fs);
        stoinoise_value(j,i) = stoi(audio, whiteNoiseaudio(i,:)', Fs);stoinoise_value1(j,i) = stoi(audio, pinkNoiseaudio(i,:)', Fs);stoinoise_value2(j,i) = stoi(audio, peopleNoiseaudio(i,:)', Fs);

    
        % 普减法
        windowLength = 256;
        overlap = round(0.75 * windowLength); % 75% overlap
        fftLength = 512;
        noiseFrames = 10; % Adjust according to your audio; depends on how long the noise-only segments are
        [stftwhiteNoisy, freqwhiteVec, timewhiteVec] = stft(whiteNoiseaudio(i,:), Fs, 'Window', hamming(windowLength, 'periodic'), 'OverlapLength', overlap, 'FFTLength', fftLength);
        [stftpinkNoisy, freqpinkVec, timepinkVec] = stft(pinkNoiseaudio(i,:), Fs, 'Window', hamming(windowLength, 'periodic'), 'OverlapLength', overlap, 'FFTLength', fftLength);
        [stftpeopleNoisy, freqpeopleVec, timepeopleVec] = stft(peopleNoiseaudio(i,:), Fs, 'Window', hamming(windowLength, 'periodic'), 'OverlapLength', overlap, 'FFTLength', fftLength);
        
        noisewhitePSD = mean(abs(stftwhiteNoisy(:, 1:noiseFrames)).^2, 2); % Power spectral density of the noise
        magwhiteNoisy = abs(stftwhiteNoisy); % Magnitude of the noisy STFT
        phasewhiteNoisy = angle(stftwhiteNoisy); % Phase of the noisy STFT
        magwhiteClean = max(magwhiteNoisy - sqrt(noisewhitePSD), 0); % Spectral subtraction
        stftwhiteClean = magwhiteClean .* exp(1j * phasewhiteNoisy); % Reconstruct the STFT with cleaned magnitude and original phase
        [cleanwhiteAudio, reconwhiteTimeVec] = istft(stftwhiteClean, Fs, 'Window', hamming(windowLength, 'periodic'), 'OverlapLength', overlap, 'FFTLength', fftLength);
        
        noisepinkPSD = mean(abs(stftpinkNoisy(:, 1:noiseFrames)).^2, 2); % Power spectral density of the noise
        magpinkNoisy = abs(stftpinkNoisy); % Magnitude of the noisy STFT
        phasepinkNoisy = angle(stftpinkNoisy); % Phase of the noisy STFT
        magpinkClean = max(magpinkNoisy - sqrt(noisepinkPSD), 0); % Spectral subtraction
        stftpinkClean = magpinkClean .* exp(1j * phasepinkNoisy); % Reconstruct the STFT with cleaned magnitude and original phase
        [cleanpinkAudio, reconpinkTimeVec] = istft(stftpinkClean, Fs, 'Window', hamming(windowLength, 'periodic'), 'OverlapLength', overlap, 'FFTLength', fftLength);

        noisepeoplePSD = mean(abs(stftpeopleNoisy(:, 1:noiseFrames)).^2, 2); % Power spectral density of the noise
        magpeopleNoisy = abs(stftpeopleNoisy); % Magnitude of the noisy STFT
        phasepeopleNoisy = angle(stftpeopleNoisy); % Phase of the noisy STFT
        magpeopleClean = max(magpeopleNoisy - sqrt(noisepeoplePSD), 0); % Spectral subtraction
        stftpeopleClean = magpeopleClean .* exp(1j * phasepeopleNoisy); % Reconstruct the STFT with cleaned magnitude and original phase
        [cleanpeopleAudio, reconpeopleTimeVec] = istft(stftpeopleClean, Fs, 'Window', hamming(windowLength, 'periodic'), 'OverlapLength', overlap, 'FFTLength', fftLength);
        
        cleanLength = length(cleanpinkAudio);  % 处理后的音频长度
        originalLength = length(whiteNoiseaudio(i,:));
        if cleanLength < originalLength
            % 如果处理后音频较短，补充零
            cleanwhiteAudio = [cleanwhiteAudio; zeros(originalLength - cleanLength, 1)];
            cleanpinkAudio = [cleanpinkAudio; zeros(originalLength - cleanLength, 1)];
            cleanpeopleAudio = [cleanpeopleAudio; zeros(originalLength - cleanLength, 1)];
        elseif cleanLength > originalLength
            % 如果处理后音频较长，截断多余部分
            cleanwhiteAudio = cleanwhiteAudio(1:originalLength);
            cleanpinkAudio = cleanpinkAudio(1:originalLength);
            cleanpeopleAudio = cleanpeopleAudio(1:originalLength);
        end
        cleanwhiteaudio(i, :) = real(cleanwhiteAudio);
        cleanpinkaudio(i, :) = real(cleanpinkAudio);
        cleanpeopleaudio(i,:) = real(cleanpeopleAudio);
        
        snrwhite_value(j,i) = snr(audio, real(cleanwhiteAudio)-audio);
        pesqwhite_value(j,i) = pesq(audio, real(cleanwhiteAudio), Fs);
        stoiwhite_value(j,i) = stoi(audio, real(cleanwhiteAudio), Fs);
    
        snrpink_value(j,i) = snr(audio, real(cleanpinkAudio)-audio);
        pesqpink_value(j,i) = pesq(audio, real(cleanpinkAudio), Fs);
        stoipink_value(j,i) = stoi(audio, real(cleanpinkAudio), Fs);
        snrpeople_value(j,i) = snr(audio, real(cleanpeopleAudio)-audio);
        pesqpeople_value(j,i) = pesq(audio, real(cleanpeopleAudio), Fs);
        stoipeople_value(j,i) = stoi(audio, real(cleanpeopleAudio), Fs);
    
        %维纳滤波
        noisewhiteSegment = whiteNoiseaudio(i,1:200);
        N = length(whiteNoiseaudio(i,:));
        noisewhitePSD = periodogram(noisewhiteSegment, [], N, Fs);
        [noisywhitePSD, whitefreq] = periodogram(whiteNoiseaudio(i,:), [], N, Fs);
        whiteH = (noisywhitePSD - noisewhitePSD) ./ noisywhitePSD;
        whiteH(whiteH < 0) = 0;
        noisywhiteSpectrum = fft(whiteNoiseaudio(i,:), N);
        filteredwhiteSpectrum = whiteH .* noisywhiteSpectrum(1:length(whiteH))';
        cleanwhiteSignal = real(ifft(filteredwhiteSpectrum, N));
        snrwhite_value1(j,i) = snr(audio, cleanwhiteSignal-audio);
        pesqwhite_value1(j,i) = pesq(audio, cleanwhiteSignal, Fs);
        stoiwhite_value1(j,i) = stoi(audio, cleanwhiteSignal, Fs);
        cleanwhiteaudio1(i,:) = cleanwhiteSignal;
        
        noisepinkSegment = pinkNoiseaudio(i,1:200);
        N = length(pinkNoiseaudio(i,:));
        noisepinkPSD = periodogram(noisepinkSegment, [], N, Fs);
        [noisypinkPSD, pinkfreq] = periodogram(pinkNoiseaudio(i,:), [], N, Fs);
        pinkH = (noisypinkPSD - noisepinkPSD) ./ noisypinkPSD;
        pinkH(pinkH < 0) = 0;
        noisypinkSpectrum = fft(pinkNoiseaudio(i,:), N);
        filteredpinkSpectrum = pinkH .* noisypinkSpectrum(1:length(pinkH))';
        cleanpinkSignal = real(ifft(filteredpinkSpectrum, N));
        snrpink_value1(j,i) = snr(audio, cleanpinkSignal-audio);
        pesqpink_value1(j,i) = pesq(audio, cleanpinkSignal, Fs);
        stoipink_value1(j,i) = stoi(audio, cleanpinkSignal, Fs);
        cleanpinkaudio1(i,:) = cleanpinkSignal;
    
        noisepeopleSegment = peopleNoiseaudio(i,1:200);
        N = length(peopleNoiseaudio(i,:));
        noisepeoplePSD = periodogram(noisepeopleSegment, [], N, Fs);
        [noisypeoplePSD, peoplefreq] = periodogram(peopleNoiseaudio(i,:), [], N, Fs);
        peopleH = (noisypeoplePSD - noisepeoplePSD) ./ noisypeoplePSD;
        peopleH(peopleH < 0) = 0;
        noisypeopleSpectrum = fft(peopleNoiseaudio(i,:), N);
        filteredpeopleSpectrum = peopleH .* noisypeopleSpectrum(1:length(peopleH))';
        cleanpeopleSignal = real(ifft(filteredpeopleSpectrum, N));
        snrpeople_value1(j,i) = snr(audio, cleanpeopleSignal-audio);
        pesqpeople_value1(j,i) = pesq(audio, cleanpeopleSignal, Fs);
        stoipeople_value1(j,i) = stoi(audio, cleanpeopleSignal, Fs);
        cleanpeopleaudio1(i,:) = cleanpeopleSignal;
    
        %MMSE
        cleanwhiteSignal = MMSE( whiteNoiseaudio(i,:), Fs);
        snrwhite_value2(j,i) = snr(audio, cleanwhiteSignal-audio);
        pesqwhite_value2(j,i) = pesq(audio, cleanwhiteSignal, Fs);
        stoiwhite_value2(j,i) = stoi(audio, cleanwhiteSignal, Fs);
        cleanwhiteaudio2(i,:) = cleanpinkSignal;
    
        cleanpinkSignal = MMSE( pinkNoiseaudio(i,:), Fs);
        snrpink_value2(j,i) = snr(audio, cleanpinkSignal-audio);
        pesqpink_value2(j,i) = pesq(audio, cleanpinkSignal, Fs);
        stoipink_value2(j,i) = stoi(audio, cleanpinkSignal, Fs);
        cleanpinkaudio2(i,:) = cleanpinkSignal;
    
        cleanpeopleSignal = MMSE( peopleNoiseaudio(i,:), Fs);
        snrpeople_value2(j,i) = snr(audio, cleanpeopleSignal-audio);  
        pesqpeople_value2(j,i) = pesq(audio, cleanpeopleSignal, Fs);
        stoipeople_value2(j,i) = stoi(audio, cleanpeopleSignal, Fs);
        cleanpeopleaudio2(i,:) = cleanpeopleSignal;
    end
end


figure;
subplot(length(db_values) + 1, 4, [1,2,3,4]);
plot(audio);
title('Original Audio');
xlabel('Sample Index');
ylabel('Amplitude');
for i = 1:length(db_values)
    subplot(length(db_values) + 1, 4, (i+1)*4-3);
    plot(whiteNoiseaudio(i, :));
    title(['whiteNoise Audio (db = ' num2str(db_values(i)) ')']);
    xlabel('Sample Index');
    ylabel('Amplitude');

    subplot(length(db_values) + 1, 4, (i+1)*4-2);
    plot(cleanwhiteaudio(i, :));
    title(['Spectral Subtraction Audio (srn = ' num2str(snrwhite_value(10,i)) ', pesq = ' num2str(pesqwhite_value(10,i)) ', stoi = ' num2str(stoiwhite_value(10,i)) ')']);
    xlabel('Sample Index');
    ylabel('Amplitude');

    subplot(length(db_values) + 1, 4, (i+1)*4-1);
    plot(cleanwhiteaudio1(i, :));
    title(['Wiener Filtering Audio (srn = ' num2str(snrwhite_value1(10,i)) ', pesq = ' num2str(pesqwhite_value1(10,i)) ', stoi = ' num2str(stoiwhite_value1(10,i)) ')']);
    xlabel('Sample Index');
    ylabel('Amplitude');

    subplot(length(db_values) + 1, 4, (i+1)*4);
    plot(cleanwhiteaudio2(i, :));
    title(['MMSE Audio (srn = ' num2str(snrwhite_value2(10,i)) ', pesq = ' num2str(pesqwhite_value2(10,i)) ', stoi = ' num2str(stoiwhite_value2(10,i)) ')']);
    xlabel('Sample Index');
    ylabel('Amplitude');
end

figure;
subplot(length(db_values) + 1, 4, [1,2,3,4]);
plot(audio);
title('Original Audio');
xlabel('Sample Index');
ylabel('Amplitude');
for i = 1:length(db_values)
    subplot(length(db_values) + 1, 4, (i+1)*4-3);
    plot(pinkNoiseaudio(i, :));
    title(['pinkNoise Audio (db = ' num2str(db_values(i)) ')']);
    xlabel('Sample Index');
    ylabel('Amplitude');

    subplot(length(db_values) + 1, 4, (i+1)*4-2);
    plot(cleanpinkaudio(i, :));
    title(['Spectral Subtraction Audio (srn = ' num2str(snrpink_value(10,i)) ', pesq = ' num2str(pesqpink_value(10,i)) ', stoi = ' num2str(stoipink_value(10,i)) ')']);
    xlabel('Sample Index');
    ylabel('Amplitude');

    subplot(length(db_values) + 1, 4, (i+1)*4-1);
    plot(cleanpinkaudio1(i, :));
    title(['Wiener Filtering Audio (srn = ' num2str(snrpink_value1(10,i)) ', pesq = ' num2str(pesqpink_value1(10,i)) ', stoi = ' num2str(stoipink_value1(10,i)) ')']);
    xlabel('Sample Index');
    ylabel('Amplitude');

    subplot(length(db_values) + 1, 4, (i+1)*4);
    plot(cleanpinkaudio2(i, :));
    title(['MMSE Audio (srn = ' num2str(snrpink_value2(10,i)) ', pesq = ' num2str(pesqpink_value2(10,i)) ', stoi = ' num2str(stoipink_value2(10,i)) ')']);
    xlabel('Sample Index');
    ylabel('Amplitude');

end

figure;
subplot(length(db_values) + 2, 4, [1,2,3,4]);
plot(audio);
title('Original Audio');
xlabel('Sample Index');
ylabel('Amplitude');

subplot(length(db_values) + 2, 4, [5,6,7,8]);
plot(noiseaudio);
title('Noise Audio');
xlabel('Sample Index');
ylabel('Amplitude');

for i = 1:length(db_values)
    subplot(length(db_values) + 2, 4, (i+2)*4-3);
    plot(peopleNoiseaudio(i, :));
    title(['PeopleNoise Audio (db = ' num2str(db_values(i)) ')']);
    xlabel('Sample Index');
    ylabel('Amplitude');

    subplot(length(db_values) + 2, 4, (i+2)*4-2);
    plot(cleanpeopleaudio(i, :));
    title(['Spectral Subtraction Audio (srn = ' num2str(snrpeople_value(10,i)) ', pesq = ' num2str(pesqpeople_value(10,i)) ', stoi = ' num2str(stoipeople_value(10,i)) ')']);
    xlabel('Sample Index');
    ylabel('Amplitude');

    subplot(length(db_values) + 2, 4, (i+2)*4-1);
    plot(cleanpeopleaudio1(i, :));
    title(['Wiener Filtering Audio (srn = ' num2str(snrpeople_value1(10,i)) ', pesq = ' num2str(pesqpeople_value1(10,i)) ', stoi = ' num2str(stoipeople_value1(10,i)) ')']);
    xlabel('Sample Index');
    ylabel('Amplitude');

    subplot(length(db_values) + 2, 4, (i+2)*4);
    plot(cleanpeopleaudio2(i, :));
    title(['MMSE Audio (srn = ' num2str(snrpeople_value2(10,i)) ', pesq = ' num2str(pesqpeople_value2(10,i)) ', stoi = ' num2str(stoipeople_value2(10,i)) ')']);
    xlabel('Sample Index');
    ylabel('Amplitude');
end

figure
subplot(131)
plot(db_values,snrwhite_value(10,:), 'r', 'DisplayName','Spectral Subtraction'); hold on;
plot(db_values,snrwhite_value1(10,:), 'g', 'DisplayName','Wiener Filtering');
plot(db_values,snrwhite_value2(10,:), 'b', 'DisplayName','MMSE');
plot(db_values,snrnoise_value(10,:), 'y', 'DisplayName','noise');
legend('show');
title('SNR with different methods in white noise')
xlabel('Db Value')
ylabel('SNR')
xticks(db_values); % 设置x轴的刻度位置
xticklabels(arrayfun(@num2str, db_values, 'UniformOutput', false)); % 将x轴的刻度标签设置为xIndex的值转换成的字符串
hold off;
subplot(132)
plot(db_values,snrpink_value(10,:), 'r', 'DisplayName','Spectral Subtraction'); hold on;
plot(db_values,snrpink_value1(10,:), 'g', 'DisplayName','Wiener Filtering');
plot(db_values,snrpink_value2(10,:), 'b', 'DisplayName','MMSE');
plot(db_values,snrnoise_value1(10,:), 'y', 'DisplayName','noise');
legend('show');
title('SNR with different methods in pink noise')
xlabel('Db Value')
ylabel('SNR')
xticks(db_values); % 设置x轴的刻度位置
xticklabels(arrayfun(@num2str, db_values, 'UniformOutput', false)); % 将x轴的刻度标签设置为xIndex的值转换成的字符串
hold off;
subplot(133)
plot(db_values,snrpeople_value(10,:), 'r', 'DisplayName','Spectral Subtraction'); hold on;
plot(db_values,snrpeople_value1(10,:), 'g', 'DisplayName','Wiener Filtering');
plot(db_values,snrpeople_value2(10,:), 'b', 'DisplayName','MMSE');
plot(db_values,snrnoise_value2(10,:), 'y', 'DisplayName','noise');
legend('show');
title('SNR with different methods in people noise')
xlabel('Db Value')
ylabel('SNR')
xticks(db_values); % 设置x轴的刻度位置
xticklabels(arrayfun(@num2str, db_values, 'UniformOutput', false)); % 将x轴的刻度标签设置为xIndex的值转换成的字符串
hold off;


figure
subplot(131)
plot(db_values,pesqwhite_value(10,:), 'r', 'DisplayName','Spectral Subtraction'); hold on;
plot(db_values,pesqwhite_value1(10,:), 'g', 'DisplayName','Wiener Filtering');
plot(db_values,pesqwhite_value2(10,:), 'b', 'DisplayName','MMSE');
plot(db_values,pesqnoise_value(10,:), 'y', 'DisplayName','noise');
legend('show');
title('PESQ with different methods in white noise')
xlabel('Db Value')
ylabel('SNR')
xticks(db_values); % 设置x轴的刻度位置
xticklabels(arrayfun(@num2str, db_values, 'UniformOutput', false)); % 将x轴的刻度标签设置为xIndex的值转换成的字符串
hold off;
subplot(132)
plot(db_values,pesqpink_value(10,:), 'r', 'DisplayName','Spectral Subtraction'); hold on;
plot(db_values,pesqpink_value1(10,:), 'g', 'DisplayName','Wiener Filtering');
plot(db_values,pesqpink_value2(10,:), 'b', 'DisplayName','MMSE');
plot(db_values,pesqnoise_value1(10,:), 'y', 'DisplayName','noise');
legend('show');
title('PESQ with different methods in pink noise')
xlabel('Db Value')
ylabel('SNR')
xticks(db_values); % 设置x轴的刻度位置
xticklabels(arrayfun(@num2str, db_values, 'UniformOutput', false)); % 将x轴的刻度标签设置为xIndex的值转换成的字符串
hold off;
subplot(133)
plot(db_values,pesqpeople_value(10,:), 'r', 'DisplayName','Spectral Subtraction'); hold on;
plot(db_values,pesqpeople_value1(10,:), 'g', 'DisplayName','Wiener Filtering');
plot(db_values,pesqpeople_value2(10,:), 'b', 'DisplayName','MMSE');
plot(db_values,pesqnoise_value2(10,:), 'y', 'DisplayName','noise');
legend('show');
title('PESQ with different methods in people noise')
xlabel('Db Value')
ylabel('SNR')
xticks(db_values); % 设置x轴的刻度位置
xticklabels(arrayfun(@num2str, db_values, 'UniformOutput', false)); % 将x轴的刻度标签设置为xIndex的值转换成的字符串
hold off;

figure
subplot(131)
plot(db_values,stoiwhite_value(10,:), 'r', 'DisplayName','Spectral Subtraction'); hold on;
plot(db_values,stoiwhite_value1(10,:), 'g', 'DisplayName','Wiener Filtering');
plot(db_values,stoiwhite_value2(10,:), 'b', 'DisplayName','MMSE');
plot(db_values,stoinoise_value(10,:), 'y', 'DisplayName','noise');
legend('show');
title('STOI with different methods in white noise')
xlabel('Db Value')
ylabel('SNR')
xticks(db_values); % 设置x轴的刻度位置
xticklabels(arrayfun(@num2str, db_values, 'UniformOutput', false)); % 将x轴的刻度标签设置为xIndex的值转换成的字符串
hold off;
subplot(132)
plot(db_values,stoipink_value(10,:), 'r', 'DisplayName','Spectral Subtraction'); hold on;
plot(db_values,stoipink_value1(10,:), 'g', 'DisplayName','Wiener Filtering');
plot(db_values,stoipink_value2(10,:), 'b', 'DisplayName','MMSE');
plot(db_values,stoinoise_value1(10,:), 'y', 'DisplayName','noise');
legend('show');
title('STOI with different methods in pink noise')
xlabel('Db Value')
ylabel('SNR')
xticks(db_values); % 设置x轴的刻度位置
xticklabels(arrayfun(@num2str, db_values, 'UniformOutput', false)); % 将x轴的刻度标签设置为xIndex的值转换成的字符串
hold off;
subplot(133)
plot(db_values,stoipeople_value(10,:), 'r', 'DisplayName','Spectral Subtraction'); hold on;
plot(db_values,stoipeople_value1(10,:), 'g', 'DisplayName','Wiener Filtering');
plot(db_values,stoipeople_value2(10,:), 'b', 'DisplayName','MMSE');
plot(db_values,stoinoise_value2(10,:), 'y', 'DisplayName','noise');
legend('show');
title('STOI with different methods in people noise')
xlabel('Db Value')
ylabel('SNR')
xticks(db_values); % 设置x轴的刻度位置
xticklabels(arrayfun(@num2str, db_values, 'UniformOutput', false)); % 将x轴的刻度标签设置为xIndex的值转换成的字符串
hold off;


function pinkNoise = generatePinkNoise(audio)
    % Create a pink noise filter
    
    pinkNoiseFilter = dsp.ColoredNoise('Color','pink', 'SamplesPerFrame', length(audio), 'NumChannels', size(audio, 2));

    pinkNoise = pinkNoiseFilter();
end