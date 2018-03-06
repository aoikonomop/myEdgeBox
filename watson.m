%% Load trained model and set up options

model=load('C:\Users\antonios.o\Documents\Projects\EdgeBoxes\myEdgeBox\edges\models\forest\modelBsds'); 
model=model.model;
model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;

opts = edgeBoxes;
opts.alpha = 0.65;     % step size of sliding window search
opts.beta  = .4;     % nms threshold for object proposals
opts.minScore = .01;  % min score of boxes to detect
opts.maxBoxes = 1e4;  % max number of boxes to detect

%% For each image in watson obtan proposals and evaluate with ground truth
base_path = 'C:\Users\antonios.o\Documents\Projects\EdgeBoxes\Watson_15000\test\';
save_path = 'C:\Users\antonios.o\Documents\Projects\EdgeBoxes\';
dircontents = dir(strcat(base_path, '*.jpg'));

% Set parameters
max_edge_size = 200;
min_confidence = 0.01;
max_aspect_ratios = [0.6 0.8 1.0];
alphas = [0.65];
betas = [.2 .4 0.65 0.75];

for a = 1:length(alphas)
    opts.alpha = alphas(a);
    for b = 1:length(betas)
        opts.beta = betas(b);
        
        image_filenames = cell(length(dircontents), 1);
        detections = cell(length(dircontents), 1);
        ground_truths = cell(length(dircontents), 1);
        projection_matrices = cell(length(dircontents), 1);

        n = 0;
        for i = 1:length(dircontents)
            n = n + 1; 
            if mod(i, 50) == 1
               fprintf('Processed image %d of %d (alpha = %f, beta = %f)\n',...
                   i, length(dircontents), opts.alpha, opts.beta);
            end

            image_filename = dircontents(i).name;
            detected_boxes = edgeBoxes(strcat(base_path,image_filename), model, opts);

            base_name = strsplit(dircontents(i).name, '.');
            [gt_boxes, projection_matrix] = ...
                get_data_from_json(strcat(base_path, base_name{1}, '.json'));

            image_filenames{i, 1} = image_filename;
            detections{i, 1} = detected_boxes;
            ground_truths{i, 1} = gt_boxes;
            projection_matrices{i, 1} = projection_matrix;

        end
        
        data = struct('image', image_filenames(1:n), ...
                      'gt', ground_truths(1:n), ...
                      'bbs', detections(1:n), ...
                      'projection_matrix', projection_matrices(1:n), ...
                      'n', length(dircontents));
                  
        save_filename = strcat('data_alpha', num2str(opts.alpha), ...
                               '_beta', num2str(opts.beta), '.mat');
        save(strcat(save_path, save_filename), 'data');
        
        for r = 1:length(max_aspect_ratios)
            filtered_detections = cell(length(dircontents), 1);
            for i = 1:length(detections)
                filtered_detections{i, 1} = filter_edge_boxes(detections{i, 1}, max_edge_size, ...
                                                              min_confidence, max_aspect_ratios(r));
            end
            
            data = struct('image', image_filenames(1:n), ...
                          'gt', ground_truths(1:n), ...
                          'bbs', filtered_detections(1:n), ...
                          'projection_matrix', projection_matrices(1:n), ...
                          'n', length(dircontents));
                      
            save_filename = strcat('data_alpha', num2str(opts.alpha), ...
                                   '_beta', num2str(opts.beta), ...
                                   '_r', num2str(max_aspect_ratios(r)), ...
                                   '_conf_th', num2str(min_confidence), ...
                                   '_edge_size', num2str(max_edge_size), '.mat');
            save(strcat(save_path, save_filename), 'data');
            clear data
        end
        
    end
end

%% Do some visualization of the result

% close all;
max_n_images = 10;

for i = 1:min(max_n_images, length(data))
    I = imread(strcat(base_path, data(i).images));
    
    figure();hold on;
    imshow(I);
    for j = 1:size(data(i).gt, 1)
        rectangle('Position', data(i).gt(j, 1:4), 'EdgeColor','b');
    end
    for j = 1:size(data(i).bbs, 1)
        rectangle('Position', data(i).bbs(j, 1:4), 'EdgeColor','r');
    end
    
end

