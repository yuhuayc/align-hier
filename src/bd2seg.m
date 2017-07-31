function segmentation = bd2seg(boundry,fmt)
%% convert boundry to segmentation
%
%  yuhua chen <yuhchen@ee.ethz.ch>
%  created on 2015.04.22

if nargin<2, fmt = 'doubleSize'; end;

if ~strcmp(fmt,'imageSize') && ~strcmp(fmt,'doubleSize')
    error('possible values for fmt are: imageSize and doubleSize');
end

temp_seg = bwlabel(~boundry);

if strcmp(fmt,'imageSize')
    segmentation = temp_seg(2:2:end,2:2:end);
else
    segmentation = temp_seg;
end

end