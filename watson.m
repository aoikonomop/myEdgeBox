%% Load trained model and set up options

model=load('edges/models/forest/modelBsds'); model=model.model;
model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;

opts = edgeBoxes;
opts.alpha = .65;     % step size of sliding window search
opts.beta  = .75;     % nms threshold for object proposals
opts.minScore = .01;  % min score of boxes to detect
opts.maxBoxes = 1e4;  % max number of boxes to detect

%% For each image in watson obtan proposals and evaluate with ground truth
dircontents = dir('C:\Users\antonios.o\Documents\Projects\EdgeBoxes\Watson_15000\*.jpg');

n = 0;

image_filenames = cell(length(dircontents), 1);
ground_truths = cell(length(dircontents), 1);

for i = 1:length(dircontents)
    
    if mod(i, 50) == 0
        fprintf('Processed image %d of %d\n', i, length(dircontents));
    end
    
    image_filename = dircontents(i).name;
    detected_boxes = edgeBoxes(image_filename, model, opts);
    
    base_name = strsplit(dircontents(i).name, '.');
    base_name = base_name{0};
    gt_obj = load_json(strcat(base_name, '.json'));
    gt_boxes = get_bbs_from_json_obj(gt_obj);
    
    if ~isempty(gt_boxes)
        n = n + 1;
        image_filenames{n, 1} = image_filename;
        ground_truths{n, 1} = gt_boxes;
    end
    
end
data = struct('images', image_filenames(1:n), 'gt', ground_truths(1:n), 'n', n);

I = imread('edges/boxes/VOCdevkit/VOC2007/JPEGImages/000647.jpg');
tic, bbs=edgeBoxes(I,model,opts); toc

clf(1)
figure(1);hold on;
imshow(I)
for i = 1:size(bbs, 1)
    if bbs(i, 5) > 0.2
        rectangle('Position', bbs(i, 1:4), 'EdgeColor','r');
    end
end