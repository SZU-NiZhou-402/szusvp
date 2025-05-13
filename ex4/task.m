clear; clc; close all;

%% 参数配置
fs = 16000; % 假设采样率
win_length = 0.025*fs; % 25ms窗长
hop_length = 0.01*fs; % 10ms帧移
energy_th1 = 0.6; % 双门限法参数
energy_th2 = 0.3;
zcr_th = 0.5;

%% 步骤1-2: 单文件处理示例
filename = 'F1.wav';
path = 'SUV';
[x, fs] = audioread(fullfile(path, filename));
ann_file = fullfile(path, strrep(filename, '.wav', '.txt'));
[s, u, v] = read_annotation(ann_file);

[energy, zcr] = extract_features(x, win_length, hop_length, fs);;

% 提取特征
features.energy = energy;
features.zcr = zcr;

% 双门限检测
det = dual_threshold_vad(features.energy, features.zcr, energy_th1, energy_th2, zcr_th);
disp(det);

% 绘制结果
S = find_regions(hop_length, fs, det == 0);
U = find_regions(hop_length, fs, det == 1);
V = find_regions(hop_length, fs, det == 2);

plot_signal_annotations(x, fs, struct('S',s,'U',u,'V',v), struct('S',S,'U',U,'V',V), filename);

%% 步骤3: 批量处理10个文件
files = dir(fullfile('audio', '*.wav'));
results = struct();
for i = 1:length(files)
    filename = files(i).name;
    [x, fs] = audioread(fullfile('audio', filename));
    
    % 提取特征
    [energy, zcr] = extract_features(x, win_length, hop_length);
    
    % 双门限检测
    det = dual_threshold_vad(energy, zcr, energy_th1, energy_th2, zcr_th);
    
    % 读取标注
    [~, name, ~] = fileparts(filename);
    ann_file = fullfile('annotations', [name '.txt']);
    [s, u, v] = read_annotation(ann_file);
    
    % 计算指标
    gt = [s; u; v];
    det_gt = [det == 0; det == 1; det == 2];
    metrics = compute_metrics(gt, det_gt);
    
    results.(name) = metrics;
end

%% 显示统计结果
metrics_table = struct2table(results);
metrics_table.Properties.VariableNames = {'File', 'FAR_v', 'MR_v', 'FAR_u', 'MR_u', 'FAR_s', 'MR_s'};
disp(metrics_table);

%% 步骤4: 加噪声处理
snrs = [0, 10, 20];
noise_types = {'gaussian', 'ssn'}; % 选做部分需补充SSN生成函数
for snr_idx = 1:length(snrs)
    for noise_type = noise_types
        for i = 1:length(files)
            % 加噪声
            [x, fs] = audioread(fullfile('audio', files(i).name));
            noisy_x = add_noise(x, snrs(snr_idx), noise_type);
            
            % 特征提取与检测
            [energy, zcr] = extract_features(noisy_x, win_length, hop_length);
            det = dual_threshold_vad(energy, zcr, energy_th1, energy_th2, zcr_th);
            
            % 计算指标（此处需重新读取标注）
            [~, name, ~] = fileparts(files(i).name);
            [~, s, u, v] = read_annotation(fullfile('annotations', [name '.txt']));
            gt = [s; u; v];
            det_gt = [det == 0; det == 1; det == 2];
            metrics = compute_metrics(gt, det_gt);
            
            % 存储结果
            results.(sprintf('%s_%ddB_%s', name, snrs(snr_idx), noise_type{1})) = metrics;
        end
    end
end

function [s, u, v] = read_annotation(filename)
    fid = fopen(filename, 'r');
    if fid == -1
        error('无法打开文件: %s，请检查文件路径是否正确。', filename);
    end
    lines = textscan(fid, '%s', 'Delimiter', '\n');
    fclose(fid);
    data = lines{1};
    
    s = []; u = []; v = [];
    for i = 1:length(data)
        line = data{i};
        if startsWith(line, 'S')
            parts = split(line, {' ', '%'});
            start = str2double(parts{3});
            endt = str2double(parts{5});
            s = [s; start endt];
        elseif startsWith(line, 'U')
            parts = split(line, {' ', '%'});
            start = str2double(parts{3});
            endt = str2double(parts{5});
            u = [u; start endt];
        elseif startsWith(line, 'V')
            parts = split(line, {' ', '%'});
            start = str2double(parts{3});
            endt = str2double(parts{5});
            v = [v; start endt];
        end
    end
end

function plot_signal_annotations(x, fs, annotations, det_annotations, title_str)
    t = (0:length(x)-1)/fs;
    figure;
    plot(t, x);
    hold on;
    
    colors = {[1 0 0 0.3], [0 1 0 0.3], [0 0 1 0.3]};
    labels = {'S', 'U', 'V'};

    % disp('绘制真实标注');
    % % 绘制真实标注
    % for i = 1:3
    %     ann = annotations.(labels{i});
    %     for j = 1:size(ann,1)
    %         start = ann(j,1);
    %         endt = ann(j,2);

    %         disp(start)
    %         disp(endt )

    %         rectangle('Position', [start, -1, endt-start, 2], ...
    %             'FaceColor', colors{i}, 'EdgeColor', 'none');
    %     end
    % end
    
    disp('绘制检测结果');
    % 绘制检测结果
    for i = 2:2
        ann = det_annotations.(labels{i});
        for j = 1:size(ann,1)
            start = ann(j,1);
            endt = ann(j,2);

            disp(start)
            disp(endt )

            rectangle('Position', [start, -0.5, endt-start, 1], ...
                'FaceColor', colors{i}, 'EdgeColor', 'none');
        end
    end
    
    ylim([-1.5 1.5]);
    legend('Signal', labels);
    title(title_str);
    xlabel('Time (s)');
    ylabel('Amplitude');
end

function [energy, zcr] = extract_features(x, win_length, hop_length, fs)
    frame_num = floor((length(x) - win_length) / hop_length) + 1;
    energy = zeros(frame_num, 1);
    zcr = zeros(frame_num, 1);
    
    for i = 1:frame_num
        start = (i-1)*hop_length + 1;
        endt = start + win_length - 1;
        frame = x(start:endt);
        
        % 计算能量（单位：能量值）
        energy(i) = sum(frame.^2);
        
        % 计算过零率（单位：次/秒）
        zcr(i) = sum(diff(sign(frame)) ~= 0) / (2 * win_length) * fs;
    end
end

function vad = dual_threshold_vad(energy, zcr, energy_th1, energy_th2, zcr_th)
    vad = zeros(size(energy));
    vad(energy > energy_th1) = 1; % 粗检测
    
    % 精检测：结合过零率
    for i = 2:length(vad)-1
        if vad(i) == 0 && vad(i-1) == 1 && zcr(i) > zcr_th
            vad(i) = 1;
        end
    end
end

function metrics = compute_metrics(gt, det)
    TP = sum(gt & det);
    FP = sum(~gt & det);
    FN = sum(gt & ~det);
    
    metrics.FAR = FP / (TP + FP) * 100;
    metrics.MR = FN / (TP + FN) * 100;
end

function regions = find_regions(hop_length, fs, det)
    % 初始化变量
    regions = struct('start', [], 'end', []);
    current_label = det(1);
    start_idx = 1;
    
    % 遍历检测结果
    for i = 2:length(det)
        if det(i) ~= current_label
            % 当前区域结束
            end_idx = i-1;
            regions(end+1).start = start_idx;
            regions(end).end = end_idx;
            
            % 新区域开始
            current_label = det(i);
            start_idx = i;
        end
    end
    
    % 处理最后一个区域
    regions(end+1).start = start_idx;
    regions(end).end = length(det);
    
    % 将帧索引转换为时间（单位：秒）
    for i = 1:numel(regions)
        regions(i).start = regions(i).start * hop_length / fs;
        regions(i).end = regions(i).end * hop_length / fs;
    end
end

function regions = find_regions_be(hop_length, fs, det)
    % 初始化变量
    regions = [];
    current_label = det(1);
    start_idx = 1;
    
    % 遍历检测结果
    for i = 2:length(det)
        if det(i) ~= current_label
            % 当前区域结束
            end_idx = i-1;
            regions = [regions; start_idx, end_idx];
            
            % 新区域开始
            current_label = det(i);
            start_idx = i;
        end
    end
    
    % 处理最后一个区域
    regions = [regions; start_idx, length(det)];
    
    % 将帧索引转换为时间（单位：秒）
    regions = regions * hop_length / fs;
end

%% 步骤5: 结果可视化
% 需要根据存储的结果绘制图表，此处省略具体实现