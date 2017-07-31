classdef segLayer
    properties
        segmentation
        regi_count
        regi_size
        regi_score
        addon_larger
        addon_smaller
    end
    
    methods
        function obj = segLayer(label_map)
            % constructor
            obj.segmentation = label_map;
            obj.regi_count = max(label_map(:));
            rstat = tabulate(label_map(:));
            obj.regi_size = rstat(:,2);
        end
        
        function ucm_board = align_ucm(obj,ucm2)
            bd_map = seg2bd(obj.segmentation,'doubleSize');
            label_board = zeros(size(ucm2));
            label_board(1:(end-1),1:(end-1)) = imresize(obj.segmentation,2,'nearest');
            label_board(end,1:(end-1)) = label_board(end-1,1:(end-1));
            label_board(1:end,end) = label_board(1:end,end-1);
            label_board(bd_map==1) = 0;
            
            ucm_board = zeros(size(ucm2));
            
            if(obj.regi_count==1)
                ucm_board = ucm2; return
            end
            
            min_strength = zeros(obj.regi_count,1);
            for i_reg = 1:obj.regi_count
                s_bd_map = seg2bd(obj.segmentation==i_reg,'doubleSize');
                min_strength(i_reg) = min(ucm2(s_bd_map==1));
            end
            
            for i_reg = 1:obj.regi_count
                ucm_board(label_board==i_reg) = ...
                    ucm2(label_board==i_reg)/(2*min_strength(i_reg));
            end
            
            mm_s = min(min_strength);
            max_s = max(ucm2(label_board==0));
            ucm_board(label_board==0) = (ucm2(label_board==0)-mm_s)*0.5/(max_s-mm_s) + 0.5;
        end
    end
end
