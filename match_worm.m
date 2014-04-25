%%%%%%%%%%%
% OPTIONS %
%%%%%%%%%%%
% Mesh Options
num_segments = 10; % number of segments in the skeleton
num_ticks = 20;    % number of times the soft body model should run

% Display Options
show_normals = 1;        % show edge normals
show_ribs = 0;           % show node placement ribs
show_node_alignment = 0; % show nodes during each tick of model

% Video Options
vid = VideoReader('shisto.avi');
start_frame = 2;
vid_scale = 0.50;

% just measure length of the normal: if it's very very short, then flip it
% around
% alternatively, figure out if we're inside the worm or not. if we are,
% great, otherwise flip it around

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% HERE THERE BE DRAGONS %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

first_frame = imresize(read(vid,start_frame),vid_scale);
mask = roipoly(first_frame);

%%
for frame_num = 1:vid.NumberOfFrames
    frame_num
    frame = imresize(read(vid,frame_num),vid_scale);
    % process image
    background = frame;
    for i = 1:3
        background(:,:,i) = roifill(frame(:,:,i),mask);
    end
    
    %find bw
    sub2 = uint8(abs(double(background) - double(frame)));
    sub2 = rgb2gray(background - frame);
    bin2 = sub2 > 10;
    bin2 = bwareaopen(bin2,50);
    bin2 = process_worm(sub2);
    average_width = 7;
     
    edges = edge(bin2,'canny',.1);
    blob = bin2;%imfill(bwmorph(edges,'dilate',2),'holes');
    skel = bwmorph(blob,'thin', inf);
    
    branches = bwmorph(skel,'endpoints');
    [branch_x branch_y] = ind2sub(size(branches), find(branches));
    
    geodesic = find(~isnan(bwdistgeodesic(skel, branch_x(1), branch_y(2))));
    
    [geo_x geo_y] = ind2sub(size(bin2), geodesic);
    
    attachment_points = skel_handles_pixels([geo_x geo_y], num_segments);
    
    %imshow(skel + edge(blob));
    imshow(rgb2gray(frame) + uint8(bin2)* 50);
    hold on;
    diff = zeros([num_segments 2])
    circle(attachment_points(1,2),attachment_points(1,1),5);
    diff(1,:) = [attachment_points(end,1) - attachment_points(1,1); ...
               attachment_points(end,2) - attachment_points(1,2)];
           
    for i = 2:num_segments;
        circle(attachment_points(i,2),attachment_points(i,1),5);
        diff(i,:) = [attachment_points(i,1) - attachment_points(i - 1,1); ...
                   attachment_points(i,2) - attachment_points(i - 1,2)];
    end
    
    dir = atan2(diff(1),diff(2));
    plot([50 50+50*cos(dir)],[50 50+50*sin(dir)])
    
    pause(0.01);
end