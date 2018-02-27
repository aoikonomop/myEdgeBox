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
