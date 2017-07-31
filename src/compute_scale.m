function [scale_arr,cvg_arr,area_arr] = compute_scale(mask, gt)
%% compute scale of segments from groundtruth
%
%  yuhua chen <yuhua.chen@vision.ee.ethz.ch>
%  created on 2016.07.25

scale_arr = zeros(max(mask(:)),1);
area_arr = zeros(max(mask(:)),1);
cvg_arr = zeros(max(mask(:)),1);

gt_stat = tabulate(gt(:));
gt_pixel_num_arr = gt_stat(:,2);

allstat = tabulate(gt(:));
allstat = allstat(:,1:2);

mask_stat = tabulate(mask(:));
mask_stat = mask_stat(:,2);

for j = 1:max(mask(:))
    s_mask = (mask==j);
    instat = tabulate(gt(s_mask));
    instat = instat(:,1:2);
%     seg_area = sum(s_mask(:));
    seg_area = mask_stat(j);
    %% correspond by cvg
    [cvg_arr(j),max_id] = max(instat(:,2)./(seg_area+allstat(instat(:,1),2)-instat(:,2)));
    corespond_gt_id = instat(max_id,1);
    gt_area = gt_pixel_num_arr(corespond_gt_id);
    scale_arr(j) = (seg_area-gt_area)/max(seg_area,gt_area);
    area_arr(j) = seg_area;
end

end