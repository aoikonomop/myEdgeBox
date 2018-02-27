function bb_matrix = get_bbs_from_json_obj(json_obj)
% Extract bounding boxes from a json object
%
% Inputs
%   json_obj : the json object containing bounding boxes
%
% Outputs
%   bb_matrix : (n x 4) matrix containing bounding boxes in 
%               (x, y, width, height) format. 

    bb_matrix = [];
    for i = 1:length(json_obj.bounding_boxes)
        bb_matrix = [bb_matrix ; ...
            json_obj.bounding_boxes(i).x ...
            json_obj.bounding_boxes(i).y ...
            json_obj.bounding_boxes(i).width ...
            json_obj.bounding_boxes(i).height];
    end

end