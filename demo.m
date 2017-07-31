%% This example demonstrates how to use hierarchy alignment.
%
%  yuhua chen <yuhua.chen@vision.ee.ethz.ch>
%  created on 2016.06.19

%% Dependencies
clear;clc;addpath src

%% Load data: hierarchy(represented as UCM) and scale value for each region are needed for alignment
load demo_data

%% Initialize the hierarchy, here we sample several layers to perform alignment. 
seg_tree = segTree(ucm);
seg_tree = seg_tree.select_layer_threshold(0.2:0.1:0.9);
seg_tree = seg_tree.init_layers;

%% Compute the scale of each segment from groundtruth. A classifier can be trained to predict the scale of segments. (In paper we use RF)
for i_layer = 1:seg_tree.layer_count
    seg_tree.layers(i_layer).regi_score = compute_scale(seg_tree.get_layer(i_layer),gt_segmentation);
end

%% Scale alignment via dynamic programming, align the best segmentation to threshold 0.5.
syn_layer = seg_tree.align_layers;
ucm_aligned = syn_layer.align_ucm(ucm);

%% Visualize alignment results
aligned_segmentation = show_segmentation(bd2seg(ucm_aligned>=0.5,'imageSize'),img);
original_segmentation = show_segmentation(bd2seg(ucm>=0.61,'imageSize'),img);  % OIS for this image is 0.61

subplot(1,3,1); imshow(img); title('image');
subplot(1,3,2); imshow(original_segmentation); title('original segmentation');
subplot(1,3,3); imshow(aligned_segmentation); title('aligned segmentation');
