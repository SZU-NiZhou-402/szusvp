function [false_alarm_rate] = FalseAlarmRate(labels, start_times, end_times, merged_labels, merged_start_times, merged_end_times, target_labels)
    false_alarm_count = 0;
    total_voiced_duration = 0;

    for i = 1:length(merged_labels)
        start_time = merged_start_times(i);
        end_time = merged_end_times(i);
        if strcmp(merged_labels{i}, target_labels)
            total_voiced_duration = total_voiced_duration + (end_time - start_time);

            is_false_alarm = true;
            for j = 1:length(labels)
                if strcmp(labels{j}, target_labels) && start_times(j) <= end_time && end_times(j) >= start_time
                    is_false_alarm = false;
                    break;
                end
            end

            if is_false_alarm
                false_alarm_count = false_alarm_count + (end_time - start_time);
            end
        end
    end

    if total_voiced_duration == 0
        false_alarm_rate = 0;
    else
        false_alarm_rate = false_alarm_count / total_voiced_duration;
    end
end

