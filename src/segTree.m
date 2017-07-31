classdef segTree
    properties
        ucm
        start_thresh
        layers
        layer_regi_counts
    end
    methods
        function obj = segTree(ucm)
            % constructor
            obj.ucm = ucm;
            bd_strength = sort(unique(ucm));
            obj.start_thresh = bd_strength;
        end
        
        function obj = select_layer_ind (obj,ind)
            % choose certain layers
            obj.start_thresh = obj.start_thresh(ind);
        end
        
        function obj = select_layer_threshold (obj,thresh_group)
            % choose certain layers from thresholds
            thresh_group = sort(thresh_group);
            ind = ones(size(thresh_group));
            for i_ind = 1:numel(ind)
                ind(i_ind) = find_layer_ind(obj,thresh_group(i_ind));
            end
            obj = select_layer_ind (obj,ind);
        end
        
        function label_map = get_layer(obj,k)
            % get the k-th layer segmentation
            label_map = bd2seg(obj.ucm>obj.start_thresh(k),'imageSize') ;
        end
        
        function ind = find_layer_ind(obj,t)
            % find the index of layer by threshold
            ind = sum(obj.start_thresh <= t);
        end
        
        function n = layer_count(obj)
            % total number of layers
            n = length(obj.start_thresh);
        end
        
        function obj = init_layers(obj)
            % total number of layers
            
            tmp_layer_regi_counts = zeros(obj.layer_count,1);
            for i_ly = 1:obj.layer_count
                tmp_layers(i_ly,1) = segLayer(obj.get_layer(i_ly));
                tmp_layer_regi_counts(i_ly) = tmp_layers(i_ly).regi_count;
            end
            obj.layers = tmp_layers;
            obj.layer_regi_counts = tmp_layer_regi_counts;
        end
        
        function mlayer = align_layers(obj)
            % align scale
            
            mlayer = obj.layers(1);
            mlayer.addon_larger = zeros(mlayer.regi_count,1);
            mlayer.addon_smaller = zeros(mlayer.regi_count,1);
            
            for i_ly = 2:obj.layer_count % merge layers from bottom to top
                mlayer = n_merge_layer(mlayer,obj.layers(i_ly));
            end
        end
    end
end

function mlayer = n_merge_layer(llayer,hlayer)
%% merge two layers
scale_lambda = 0.1;
hth = 0;
lth = 0;
perfectth = 0;

size_gamma = 0.5;

mboard = zeros(size(llayer.segmentation));
mcount = 0;
mscore = [];
alarger = [];
asmaller = [];

hlayer.regi_size = (hlayer.regi_size).^(size_gamma);
llayer.regi_size = (llayer.regi_size).^(size_gamma);

for i_rg = 1:hlayer.regi_count
    sel_bool = (hlayer.segmentation == i_rg);
    
    lindx = unique(llayer.segmentation(sel_bool));
    if(length(lindx)==1)
        hwin_bool = 1;
    else
        hwinterm = abs(hlayer.regi_score(i_rg)-perfectth)*hlayer.regi_size(i_rg) ...
            + scale_lambda*sum(llayer.addon_larger(lindx));
        lwinterm = sum(abs(llayer.regi_score(lindx)-perfectth).*llayer.regi_size(lindx)) ...
            + scale_lambda*sum(llayer.addon_smaller(lindx));
        hwin_bool = (hwinterm<lwinterm);
    end
    if(hwin_bool)
        mcount = mcount+1;
        mboard(sel_bool) = mcount;
        mscore(mcount,1) = hlayer.regi_score(i_rg);
        alarger(mcount,1) = 0;
        asmaller(mcount,1) = 0;
    else
        for i_lindx = 1:length(lindx)
            mcount = mcount+1;
            mboard(llayer.segmentation==lindx(i_lindx)) = mcount;
            mscore(mcount,1) = llayer.regi_score(lindx(i_lindx));
            alarger(mcount,1) = llayer.addon_larger(lindx(i_lindx));
            asmaller(mcount,1) = llayer.addon_smaller(lindx(i_lindx));
        end
        
        if(hlayer.regi_score(i_rg)>hth)
            alarger(mcount,1) = alarger(mcount,1)+hlayer.regi_size(i_rg);
        end
        if(hlayer.regi_score(i_rg)<lth)
            asmaller(mcount,1) = alarger(mcount,1)+hlayer.regi_size(i_rg);
        end
    end
end
mlayer = segLayer(mboard);
mlayer.regi_score = mscore;
mlayer.addon_larger = alarger;
mlayer.addon_smaller = asmaller;
end

