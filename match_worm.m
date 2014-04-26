clear;
clf;
%%%%%%%%%%%
% OPTIONS %
%%%%%%%%%%%
% Mesh Options
num_segments = 10; % number of segments in the skeleton
num_ticks = 20;    % number of times the soft body model should run

% Display Options
show_normals = 0; % show edge normals

% Video Options
vid = VideoReader('shisto.avi');
start_frame = 400;
vid_scale = 0.50;

system = ParticleSystem();
log = Logger('test.log',0,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% HERE THERE BE DRAGONS %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


first_frame = imresize(read(vid,start_frame),vid_scale);
mask = roipoly(first_frame);

%%
for frame_num = start_frame:vid.NumberOfFrames
    frame_num
    frame = imresize(read(vid,frame_num),vid_scale);
    % process image
    background = frame;
    for i = 1:3
        background(:,:,i) = roifill(frame(:,:,i),mask);
    end
    
    %find bw
    %sub2 = uint8(abs(double(background) - double(frame)));
    %sub2 = rgb2gray(sub2);
    %bin2 = sub2 > 10;
    %bin2 = bwareaopen(bin2,50);
    sub2 = rgb2gray(background - frame);
    bin2 = process_worm(sub2);
    
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
    %imshow(rgb2gray(frame) + uint8(bin2)* 50);
    %hold on;
    
    diff = zeros([num_segments 2]);
    diff(1,:) = [attachment_points(end,1) - attachment_points(1,1); ...
               attachment_points(end,2) - attachment_points(1,2)];
         
    for i = 2:num_segments
        diff(i,:) = [attachment_points(end,1) - attachment_points(1,1); ...
                     attachment_points(end,2) - attachment_points(1,2)];
    end
       
    angles = atan2(diff(:,1),diff(:,2));
    a_edges = [];
    b_edges = [];
    search_target = imdilate(edges,ones(2));
    
    hold off;
    %imshow(search_target + skel);
    imshow(frame);
    hold on;
    
    for i = 1:num_segments
        seg_x = attachment_points(i,2);
        seg_y = attachment_points(i,1);
        a_normal = NaN;
        b_normal = NaN;
        dir = angles(i);
        for n = 1:round(3*dist)+1
            n = n - 1;
            a_x = round(seg_x + cos(dir+pi/2)*n);
            a_y = round(seg_y + sin(dir+pi/2)*n);
            
            b_x = round(seg_x + cos(dir-pi/2)*n);
            b_y = round(seg_y + sin(dir-pi/2)*n);
            
            search_target(a_y, a_x)
         
            
            if(search_target(a_y, a_x) == 1)
                if(isnan(a_normal))
                    a_normal = [a_x a_y];
                    a_edges = [a_edges Edge(a_x, a_y)];
                    if(show_normals)
                        plot([seg_x a_x],[seg_y a_y]);
                    end
                end
            end
            
            if(search_target(b_y, b_x) == 1)
                if(isnan(b_normal))
                    b_normal = [b_x b_y];
                    b_edges = [b_edges Edge(b_x, b_y)];
                    if(show_normals)
                        plot([seg_x b_x],[seg_y b_y],'r');
                    end
                end
            end
        end               
    end
    
    if(frame_num > start_frame)
        for i = 1:num_segments
            i
            right_node = system.NODES(i*3);
            center_node = system.NODES(i*3-1);
            left_node = system.NODES(i*3-2);
            
            right_node.position(1) = a_edges(i).i;
            right_node.position(2) = a_edges(i).j;
            
            left_node.position(1) = b_edges(i).i;
            left_node.position(2) = b_edges(i).j;
            
            right_node.reset_physics;
            center_node.reset_physics;
            left_node.reset_physics;
        end            
    else
        for(i = 1:num_segments)
            % create NODES and SPRINGS
            left_edge  = Node(i*3 - 2, [a_edges(i).i    a_edges(i).j],   [0 0],10, 0.5, 1);
            spine      = Node(i*3 - 1, [attachment_points(i,2) attachment_points(i,1)],[0 0],10, 0.5, 0);
            right_edge = Node(i*3,     [b_edges(i).i    b_edges(i).j], [0 0],10, 0.5, 1);
            % a node is spine %
            k = 0.5;
            damp = 0.1;
            spring_id_base = system.num_springs;
            left_spring  = Spring(spring_id_base + 1, 6*vid_scale, k, damp, spine, left_edge);
            right_spring = Spring(spring_id_base + 2, 6*vid_scale, k, damp, spine, right_edge);
            if(i > 1)
                % a is previous node
                left_connector  = Spring(spring_id_base + 3, 2, k, damp, system.NODES((i-1)*3 - 2), left_edge);
                spine_connector = Spring(spring_id_base + 4, 2, k, damp, system.NODES((i-1)*3 - 1), spine);
                right_connector = Spring(spring_id_base + 5, 2, k, damp, system.NODES((i-1)*3), right_edge);
            end

           % populate lists
            system.add_node(left_edge);
            system.add_node(spine);
            system.add_node(right_edge);

            system.add_spring(left_spring);
            system.add_spring(right_spring);
            if(i > 1)
                system.add_spring(left_connector);
                system.add_spring(spine_connector);
                system.add_spring(right_connector);
            end
        end
    end
    for(iteration = 1:num_ticks)
        system.tick();
    end
    for(i = 1:system.num_nodes)
        this_node = system.NODES(i);
        %circle(this_node.position(1), this_node.position(2), 3);
        % draw mesh
        for(n = 1:length(this_node.attached_nodes))
            plot([this_node.position(1) this_node.attached_nodes(n).position(1)],...
              [this_node.position(2) this_node.attached_nodes(n).position(2)],'g');
        end
    end
    
    pause(0.01);
end