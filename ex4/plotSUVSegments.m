% 定义函数
function plotSUVSegments(labels, start_times, end_times, t, x)
    figure;
    plot(t, x);
    hold on;
    xlabel('Time (s)');
    ylabel('Amplitude');
    title('Waveform with SUV Segments');
    grid on;
    xlim([0 max(t)]);
    ylim([-1 1]);

    for i = 1:length(labels)
         % 获取起始和结束时间
         start_time = start_times(i);
         end_time = end_times(i);

         % 找到对应的时间索引
         start_index = find(t >= start_time, 1, 'first');
         end_index = find(t <= end_time, 1, 'last');

         % 绘制标注区域
         fill([t(start_index) t(end_index) t(end_index) t(start_index)], ...
               [-1 -1 1 1], 'r', 'FaceAlpha', 0.3, 'EdgeColor', 'none');

         % 在标注区域上方添加标签
         text(mean([t(start_index) t(end_index)]), 0.8, labels{i}, ...
               'HorizontalAlignment', 'center', 'Color', 'k', 'FontSize', 10);
    end
    hold off;
    legend('Waveform', 'SUV Segments');
    axis tight;
    set(gca, 'YTick', [-1 0 1], 'YTickLabel', {'-1', '0', '1'});
    set(gca, 'XTick', 0:0.5:max(t), 'XTickLabel', arrayfun(@(x) sprintf('%.1f', x), 0:0.5:max(t), 'UniformOutput', false));
    set(gca, 'FontSize', 12);
    set(gca, 'FontName', 'Arial');
end
