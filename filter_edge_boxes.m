function bbs = filter_edge_boxes(bbs, min_edge_size, ...
                min_confidence, min_aspect_ratio)
% Filter bounding boxes according to minimum edge size
% and minimum confidence.
%
% Inputs
%   bbs : (N x 5) array containing edge boxes of a certain frame. 
%
%   min_edge_size : int, the minimum allowed size in pixels of an edgebox
%
%   min_confidence : float, the minimum allowed confidence of an edgebox
%
%   min_sapect_ratio : float, the minimum allowed ratio between width and 
%                      height of each bounding box
%
% Outputs
%   bbs : (M x 5) (M <= N) array containing the filtered edgeboxes. 

accepted_idx = [];
for j = 1:size(bbs, 1)
    if (bbs(j, 5) > min_confidence && ...
        bbs(j, 3) < min_edge_size && ...
        bbs(j, 4) < min_edge_size)

        % Only accept boxes whose width is smaller than their height. 
        if bbs(j, 3) / bbs(j, 4) < min_aspect_ratio
            accepted_idx = [accepted_idx ; j];
        end

    end
end
bbs = bbs(accepted_idx, :);
