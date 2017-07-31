function vis_map = show_segmentation(seg_map, img)
%% visualize segmentation
%
%  yuhua chen <yuhchen@ee.ethz.ch>
%  created on 2015.06.09

vis_map = zeros([size(seg_map),3]);
vis_map_r = zeros(size(seg_map));
vis_map_g = zeros(size(seg_map));
vis_map_b = zeros(size(seg_map));

imgr = img(:,:,1);
imgg = img(:,:,2);
imgb = img(:,:,3);

for icl_ = 1:length(unique(seg_map))
    vis_map_r(seg_map==icl_) = mean(imgr(seg_map==icl_));
    vis_map_g(seg_map==icl_) = mean(imgg(seg_map==icl_));
    vis_map_b(seg_map==icl_) = mean(imgb(seg_map==icl_));
end

seg_bd = seg2bd(seg_map,'imageSize');

vis_map_r(seg_bd>0) = 0;
vis_map_g(seg_bd>0) = 0;
vis_map_b(seg_bd>0) = 0;

vis_map(:,:,1) = vis_map_r;
vis_map(:,:,2) = vis_map_g;
vis_map(:,:,3) = vis_map_b;

vis_map = uint8(vis_map);

end