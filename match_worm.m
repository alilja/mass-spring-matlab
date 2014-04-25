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
    dist = max(max(bwdist(~bin2),[],1));
    
    endpoints = bwmorph(skel,'endpoints');
    [ep_x ep_y] = ind2sub(size(endpoints), find(endpoints));
    
    geodesic = find(~isnan(bwdistgeodesic(skel, ep_x(1), ep_y(2))));
    [geo_x geo_y] = ind2sub(size(bin2), geodesic);
    attachment_points = skel_handles_pixels([geo_x geo_y], num_segments);
    
    %imshow(skel + edge(blob));
    imshow(rgb2gray(frame) + uint8(bin2)* 50);
    hold on;
    
    diff = zeros([num_segments 2]);
    diff(1,:) = [attachment_points(end,1) - attachment_points(1,1); ...
               attachment_points(end,2) - attachment_points(1,2)];
         
    circle(attachment_points(1,2),attachment_points(1,1),5);
    for i = 2:num_segments
        circle(attachment_points(i,2),attachment_points(i,1),5);
        diff(1,:) = [attachment_points(i,1) - attachment_points(i-1,1); ...
                     attachment_points(i,2) - attachment_points(i-1,2)];
    end
       
    angles = atan2(diff(:,1),diff(:,2));
    a_edges = [];
    b_edges = [];
    search_target = imdilate(edges,ones(2));
    imshow(search_target);
    hold on;
    for i = 1:num_segments
        seg_x = attachment_points(i,2);
        seg_y = attachment_points(i,1);
        a_normal = NaN;
        b_normal = NaN;
        dir = angles(i);
        for n = 1:round(3*dist)+1
            n = n - 1;
            a_x = round(seg_x + cos(dir+pi/2)*n)
            a_y = round(seg_y + sin(dir+pi/2)*n)
            
            b_x = round(seg_x + cos(dir-pi/2)*n);
            b_y = round(seg_y + sin(dir-pi/2)*n);
            
            search_target(a_y, a_x)
         
            
            if(search_target(a_y, a_x) == 1)
                if(isnan(a_normal))
                    a_normal = [a_x a_y];
                    a_edges = [a_edges Edge(a_x, a_y)];
                    plot([seg_x a_x],[seg_y a_y]);
                end
            end
            
            if(search_target(b_y, b_x) == 1)
                if(isnan(b_normal))
                    b_normal = [b_x b_y];
                    b_edges = [b_edges Edge(b_x, b_y)];
                    plot([seg_x b_x],[seg_y b_y],'r');
                end
            end
        end
                
    end
    pause(0.01);
    k = waitforbuttonpress();
end