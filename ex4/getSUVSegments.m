function [merged_labels, merged_start_times, merged_end_times] = getSUVSegments(x, fs)
    % 参数设置
    frame_size = 0.02; % 帧长（秒）
    frame_shift = 0.02; % 帧移（秒）
    frame_length = round(frame_size * fs); % 帧长（采样点数）
    frame_step = round(frame_shift * fs); % 帧移（采样点数）

    % 分帧
    num_frames = floor((length(x) - frame_length) / frame_step) + 1;
    frames = zeros(num_frames, frame_length);
    for i = 1:num_frames
        start_idx = (i-1) * frame_step + 1;
        end_idx = start_idx + frame_length - 1;
        frames(i, :) = x(start_idx:end_idx);
    end

    % 计算短时能量
    short_time_energy = sum(frames.^2, 2);

    % 设置双门限
    high_threshold = 0.02; % 高阈值
    low_threshold = 0.01;  % 低阈值

    % 基于双门限法的分类
    detected_labels = strings(num_frames, 1);
    for i = 1:num_frames
        if short_time_energy(i) > high_threshold
            detected_labels(i) = "V"; % 有声段
        elseif short_time_energy(i) > low_threshold
            detected_labels(i) = "U"; % 无声段
        else
            detected_labels(i) = "S"; % 静音段
        end
    end

    % 将检测结果映射到时间轴
    detected_start_times = (0:num_frames-1) * frame_shift;
    detected_end_times = detected_start_times + frame_size;

    % 合并连续的相同检测结果
    merged_labels = detected_labels(1); % 初始化合并后的标签
    merged_start_times = detected_start_times(1); % 初始化合并后的起始时间
    merged_end_times = detected_end_times(1); % 初始化合并后的结束时间

    for i = 2:length(detected_labels)
        if detected_labels(i) == merged_labels(end)
            % 如果当前标签与前一个相同，则更新结束时间
            merged_end_times(end) = detected_end_times(i);
        else
            % 如果当前标签与前一个不同，则添加新的标签和时间
            merged_labels = [merged_labels; detected_labels(i)];
            merged_start_times = [merged_start_times; detected_start_times(i)];
            merged_end_times = [merged_end_times; detected_end_times(i)];
        end
    end

    merged_start_times = double(merged_start_times);
    merged_end_times = double(merged_end_times);
end