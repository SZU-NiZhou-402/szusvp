function [Missing_Rate] = MissingRate(labels, start_times, end_times, merged_labels, merged_start_times, merged_end_times, target_labels)
    missing_count = 0;
    
    total_voiced_duration = 0;
    for i = 1:length(labels)
        if strcmp(labels(i), target_labels)
            total_voiced_duration = total_voiced_duration + (end_times(i) - start_times(i));
        end
    end
    
    for i = 1:length(labels)
        if strcmp(labels(i), target_labels)
            start_time = start_times(i);
            end_time = end_times(i);
            
            is_missing = true;
            for j = 1:length(merged_labels)
                if strcmp(merged_labels(j), target_labels) && merged_start_times(j) <= end_time && merged_end_times(j) >= start_time
                    is_missing = false;
                    break;
                end
            end
            
            if is_missing
                missing_count = missing_count + (end_time - start_time);
            end
        end
    end
    
    Missing_Rate = missing_count / total_voiced_duration;
end
