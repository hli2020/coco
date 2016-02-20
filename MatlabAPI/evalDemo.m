%% Demo demonstrating the algorithm result formats for COCO
clc; close all; clear;

% select results type for demo (either bbox or segm)
type = {'segm', 'bbox'};
% specify type here
type = type{2}; 
fprintf('Running demo for *%s* results.\n\n', type);

% initialize COCO ground truth api
dataDir = '..'; 
dataType = 'val2014';
annFile = sprintf('%s/annotations/instances_%s.json', dataDir, dataType);
if(~exist('cocoGt','var')) 
    cocoGt = CocoApi(annFile); 
end

% initialize COCO detections api
resFile = '%s/results/instances_%s_fake%s100_results.json';
resFile = sprintf(resFile, dataDir, dataType, type);
cocoDt = cocoGt.loadRes(resFile);

%% visialuze gt and dt side by side
imgIds = sort(cocoGt.getImgIds()); 
imgIds = imgIds(1:100);
im_id = imgIds(randi(100)); 
im = cocoGt.loadImgs(im_id);
I = imread(sprintf('%s/../val2014/%s', dataDir, im.file_name));

figure(1); subplot(1,2,1); imagesc(I); axis('image'); axis off;
% unique, instance-leve id
ann_Ids = cocoGt.getAnnIds('imgIds', im_id); 
title('ground truth');
% structure
gt_annos = cocoGt.loadAnns(ann_Ids); 
cocoGt.showAnns(gt_annos);

figure(1); subplot(1,2,2); imagesc(I); axis('image'); axis off;
ann_Ids = cocoDt.getAnnIds('imgIds', im_id); 
title('results');
res_annos = cocoDt.loadAnns(ann_Ids); 
cocoDt.showAnns(res_annos);

%% load raw JSON and show exact format for results
fprintf('results structure have the following format:\n');
res = gason(fileread(resFile)); 
disp(res);

% the following command can be used to save the results back to disk
if(0), f = fopen(resFile, 'w'); fwrite(f, gason(res)); fclose(f); end

%% run Coco evaluation code (see CocoEval.m)
cocoEval = CocoEval(cocoGt, cocoDt);
cocoEval.params.imgIds = imgIds;
cocoEval.params.useSegm = strcmp(type, 'segm');
cocoEval.evaluate();
cocoEval.accumulate();
cocoEval.summarize();
