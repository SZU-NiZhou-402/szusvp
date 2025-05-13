function [s, u, v] = read_annotation(filename)
    fid = fopen(filename, 'r');
    lines = textscan(fid, '%s', 'Delimiter', '\n');
    fclose(fid);
    data = lines{1};
    
    s = []; u = []; v = [];
    for i = 1:length(data)
        line = data{i};
        if startsWith(line, 'S')
            parts = split(line, {' ', '%'});
            start = str2double(parts{2});
            endt = str2double(parts{3});
            s = [s; start endt];
        elseif startsWith(line, 'U')
            parts = split(line, {' ', '%'});
            start = str2double(parts{2});
            endt = str2double(parts{3});
            u = [u; start endt];
        elseif startsWith(line, 'V')
            parts = split(line, {' ', '%'});
            start = str2double(parts{2});
            endt = str2double(parts{3});
            v = [v; start endt];
        end
    end
end

function plot_signal_annotations(x, fs, annotations, det_annotations, title_str)
    t = (0:length(x)-1)/fs;
    figure;
    plot(t, x);
    hold on;
    
    colors = {'r', 'g', 'b'};
    labels = {'Silence', 'Unvoiced', 'Voiced'};
    
    % 绘制真实标注
    for i = 1:3
        ann = annotations.(labels{i});
        for j = 1:size(ann,1)
            start = ann(j,1);
            endt = ann(j,2);
            rectangle('Position', [start, -1, endt-start, 2], ...
                'FaceColor', colors{i}, 'EdgeColor', 'none', 'FaceAlpha', 0.3);
        end
    end
    
    % 绘制检测结果
    for i = 1:3
        ann = det_annotations.(labels{i});
        for j = 1:size(ann,1)
            start = ann(j,1);
            endt = ann(j,2);
            rectangle('Position', [start, -0.5, endt-start, 1], ...
                'FaceColor', colors{i}, 'EdgeColor', 'none', 'FaceAlpha', 0.5);
        end
    end
    
    ylim([-1.5 1.5]);
    legend('Signal', labels);
    title(title_str);
    xlabel('Time (s)');
    ylabel('Amplitude');
end

function [energy, zcr] = extract_features(x, win_length, hop_length)
    frame_num = floor((length(x) - win_length)/hop_length) + 1;
    energy = zeros(frame_num, 1);
    zcr = zeros(frame_num, 1);
    
    for i = 1:frame_num
        start = (i-1)*hop_length + 1;
        endt = start + win_length - 1;
        frame = x(start:endt);
        
        energy(i) = sum(frame.^2);
        zcr(i) = sum(diff(sign(frame)) ~= 0)/win_length * fs;
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