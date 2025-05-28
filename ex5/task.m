clc;clear;
[x, Fs] = audioread('ex3/task1.wav');

% 设置参数
mu_values = [10, 100, 250, 400, 500];
bit_depth = 8;
sample_rate = 8000;

% 初始化存储结果的矩阵
encoded_signals = zeros(length(mu_values), length(x));
decoded_signals = zeros(length(mu_values), length(x));
snr_values = zeros(length(mu_values), 1);

% 循环处理不同的mu值
for i = 1:length(mu_values)
    mu = mu_values(i);
    
    % 编码
    encoded = sign(x) .* log(1 + mu * abs(x)) / log(1 + mu);
    encoded = round(encoded * (2^(bit_depth-1) - 1));
    encoded = int16(encoded);
    
    % 解码
    decoded = double(encoded) / (2^(bit_depth-1) - 1);
    decoded = sign(decoded) .* ((1 + mu).^abs(decoded) - 1) / mu;
    
    % 存储编解码结果
    encoded_signals(i, :) = encoded;
    decoded_signals(i, :) = decoded;
    
    % 计算信噪比
    snr_values(i) = snr(x, decoded - x);
end

% 绘制编解码语音和原始语音的波形图
figure;
subplot(length(mu_values) + 1, 1, 1);
plot(x);
title('Original Audio');
xlabel('Sample Index');
ylabel('Amplitude');

for i = 1:length(mu_values)
    subplot(length(mu_values) + 1, 1, i+1);
    plot(decoded_signals(i, :));
    title(['Decoded Audio (μ = ' num2str(mu_values(i)) ')']);
    xlabel('Sample Index');
    ylabel('Amplitude');
end

% 打印信噪比结果
fprintf('SNR values:\n');
for i = 1:length(mu_values)
    fprintf('μ = %d: %.2f dB\n', mu_values(i), snr_values(i));
end

mu = 50;
bit_depth_values = [4, 6, 10];
decoded_signals = zeros(length(bit_depth_values), length(x));
snr_values = zeros(length(bit_depth_values), 1);

% 循环处理不同的比特数
for i = 1:length(bit_depth_values)
    bit_depth = bit_depth_values(i);
    
    % 编码
    encoded = sign(x) .* log(1 + mu * abs(x)) / log(1 + mu);
    encoded = round(encoded * (2^(bit_depth-1) - 1));
    encoded = int16(encoded);
    
    % 解码
    decoded = double(encoded) / (2^(bit_depth-1) - 1);
    decoded = sign(decoded) .* ((1 + mu).^abs(decoded) - 1) / mu;
    
    % 存储解码结果
    decoded_signals(i, :) = decoded;
    
    % 计算信噪比
    snr_values(i) = snr(x, decoded - x);
end

bit_depth = 6;
reconstructed = zeros(size(x));
% 确保不会超出数组边界
max_samples = length(x) - 201;
for i = 1:200:max_samples
    mu_x = mean(abs(x(i:i+200)));
    sigma_x = std(abs(x(i:i+200)));

    if abs(mu_x) < 0.2 * max(abs(x(i:i+200))) && sigma_x < 0.2 * max(abs(x(i:i+200)))
        mu1 = mu * 1.2;
    elseif abs(mu_x) > 0.6 * max(abs(x(i:i+200))) || sigma_x > 0.6 * max(abs(x(i:i+200)))
        mu1 = mu * 0.8;
    else
        mu1 = mu;
    end

    encoded = sign(x(i:i+200)) .* log(1 + mu1 * abs(x(i:i+200))) / log(1 + mu1);
    encoded = round(encoded * (2^(bit_depth-1) - 1));
    encoded = int16(encoded);

    decoded = double(encoded) / (2^(bit_depth-1) - 1);
    decoded = sign(decoded) .* ((1 + mu1).^abs(decoded) - 1) / mu1;
    reconstructed(i:i+200) = decoded;
end

snr_ = snr(x(1:max_samples), reconstructed(1:max_samples)-x(1:max_samples));

% 绘制解码语音和原始语音的波形图
figure;
subplot(length(bit_depth_values) + 1, 1, 1);
plot(x);
title('Original Audio');
xlabel('Sample Index');
ylabel('Amplitude');

for i = 1:length(bit_depth_values)
    subplot(length(bit_depth_values) + 1, 1, i+1);
    plot(decoded_signals(i, :));
    title(['Decoded Audio (Bit Depth = ' num2str(bit_depth_values(i)) ')']);
    xlabel('Sample Index');
    ylabel('Amplitude');
end

% 打印信噪比结果
fprintf('SNR values:\n');
for i = 1:length(bit_depth_values)
    fprintf('Bit Depth = %d: %.2f dB\n', bit_depth_values(i), snr_values(i));
end

figure;
subplot(211);plot(x);title('Original Audio');xlabel('Sample Index');ylabel('Amplitude');
subplot(212);plot(reconstructed);title('Adaptive Audio');xlabel('Sample Index');ylabel('Amplitude');

%%% LPC 分析部分
t = length(x)/Fs; % signal duration
p = 10;  % filter order

fr = 0.02;    % frame size=20ms
frm_len = round(Fs*fr); % no of samples in a frame
n = frm_len-1;

% 预分配数组
total_frames = floor((length(x)-frm_len)/frm_len);
pitch_freq = zeros(1, length(x));
pitch_per = zeros(1, length(x));
v_uv = zeros(1, length(x));
A = zeros(1, length(x));
dec_aud = zeros(1, length(x));

% voiced/unvoiced & pitch
for frm = 1:frm_len:(length(x)-frm_len)
    y = x(frm:frm+n);
    autocor = xcorr(y);
    [~,ind] = findpeaks(autocor);
    if length(ind) > 1
        curr_pitch_freq = mean(Fs./diff(ind));
        curr_pitch_per = 1/curr_pitch_freq;
        
        pitch_freq(frm:frm+n) = curr_pitch_freq;
        pitch_per(frm:frm+n) = curr_pitch_per;
        
        % 检查是否在正常的人声频率范围内
        if curr_pitch_freq >= 80 && curr_pitch_freq <= 350
            v_uv(frm:frm+n) = 1;
        end
    end
end

% Coefficients and gain (levinson-durbin method)
for frm = 1:frm_len:(length(x)-frm_len)
    y = x(frm:frm+n);    
    q = lpc(y,p);
    num_co = length(q);
    y_estm = filter([0 -q(2:end)],1,y);    
    e = y-y_estm;

    A(frm:frm+num_co-1) = q;
    
    if v_uv(frm) == 0
        gain(frm) = sqrt(sum(e.^2)/length(e)); % sqrt(MSE)
    else      
        denom = floor(length(e)/pitch_per(frm))*pitch_per(frm);
        if denom > 0
            gain(frm) = sqrt(pitch_per(frm)*sum(e(1:floor(denom)).^2)/denom);
        end
    end
end

% 合成
for frm = 1:frm_len:min(length(gain), length(x)-frm_len)
    pulse_tr = zeros(1, frm_len);
    
    if v_uv(frm) == 1 % voiced
        if pitch_per(frm) > 0
            for h = 1:frm_len
                if mod(h, round(pitch_per(frm))) == 0
                    pulse_tr(h) = 1;
                end
            end
        end
        
        % 确保滤波器系数有效
        filter_coeffs = A(frm+1:min(frm+p, length(A)));
        if ~isempty(filter_coeffs) && all(isfinite(filter_coeffs))
            w = filter(1, [1 filter_coeffs], pulse_tr);
        else
            w = zeros(1, frm_len); % 如果系数无效，使用零信号
        end
    else % unvoiced
        wn = randn(1, frm_len)*0.1;
        % 确保滤波器系数有效
        filter_coeffs = A(frm+1:min(frm+p, length(A)));
        if ~isempty(filter_coeffs) && all(isfinite(filter_coeffs))
            w = filter(1, [1 filter_coeffs], wn);
        else
            w = wn; % 如果系数无效，直接使用白噪声
        end
    end
    
    % 检查输出是否有效
    if any(~isfinite(w))
        w = zeros(1, length(w)); % 如果输出无效，使用零信号
    end
    
    % 更新解码音频
    end_idx = min(frm+frm_len-1, length(dec_aud));
    w_len = min(frm_len, length(dec_aud)-frm+1);
    if w_len > 0
        dec_aud(frm:end_idx) = w(1:w_len);
    end
end

% 确保最终信号不包含无限值
dec_aud(~isfinite(dec_aud)) = 0;

figure;
subplot(2,1,1);
plot(x);
title('Input Audio Signal');
xlabel('Sample Index');
ylabel('Amplitude');
subplot(2,1,2);
plot(dec_aud);
title('LPC-decoded Audio Signal');
xlabel('Sample Index');
ylabel('Amplitude');

% 计算最终的SNR
valid_length = min(length(x), length(dec_aud));
e = x(1:valid_length) - dec_aud(1:valid_length)';

% 检查是否有无限值或NaN
if any(~isfinite(e))
    % 移除无限值和NaN
    valid_indices = isfinite(x(1:valid_length)) & isfinite(dec_aud(1:valid_length));
    x_valid = x(valid_indices);
    e_valid = x_valid - dec_aud(valid_indices)';
    
    if ~isempty(x_valid)
        final_snr = snr(x_valid, e_valid);
        fprintf('Final SNR (after removing invalid values): %.2f dB\n', final_snr);
    else
        fprintf('Warning: No valid data points for SNR calculation\n');
        final_snr = NaN;
    end
else
    final_snr = snr(x(1:valid_length), e);
    fprintf('Final SNR: %.2f dB\n', final_snr);
end

if isfinite(snr_)
    fprintf('Adaptive μ-law SNR: %.2f dB\n', snr_);
else
    fprintf('Warning: Invalid adaptive μ-law SNR value\n');
end