function [bb_matrix, projection_matrix] = get_data_from_json(filename)
% Extract bounding boxes from a json object
%
% Inputs
%   filename : str, the input json filename
%
% Outputs
%   bb_matrix : (n x 4) array containing bounding boxes in 
%               (x, y, width, height) format. 
%   projection_matrix : (4 x 3) array containing the frame's
%                       projection matrix.

    json_obj = load_json(filename);

    bb_matrix = [];
    for i = 1:length(json_obj.bounding_boxes)
        bb_matrix = [bb_matrix ; ...
            json_obj.bounding_boxes(i).x ...
            json_obj.bounding_boxes(i).y ...
            json_obj.bounding_boxes(i).width ...
            json_obj.bounding_boxes(i).height];
    end
    projection_matrix = json_obj.projection_matrix;

end


function json_obj = load_json(filename)
% Load a json file and return as a struct object
%
% Inputs
%   filename : str, the input filename
%
% Outputs
%   json_obj : the output json object

    fid = fopen(filename); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
    json_obj = jsondecode(str);

end
