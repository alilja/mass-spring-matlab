% TO DO
% 1. work on sorting nodes by location
% 2. add video

%%%%%%%%%%%
% OPTIONS %
%%%%%%%%%%%
% Mesh Options
num_segments = 10; % number of segments in the skeleton
num_ticks = 20;    % number of times the soft body model should run

% Display Options
show_normals = 1;        % show edge normals
show_ribs = 1;           % show node placement ribs
show_node_alignment = 0; % show nodes during each tick of model

% Video Options
vid = VideoReader('shisto.avi');
start_frame = 2;
vid_scale = 0.50;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% HERE THERE BE DRAGONS %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% calculate options, pseudo-bitwise
show_stuff = show_normals + show_ribs + show_node_alignment;

% process image
first_frame = imresize(read(vid,start_frame),vid_scale);
mask = roipoly(first_frame);
background = first_frame;
for i = 1:3
    background(:,:,i) = roifill(first_frame(:,:,i),mask);
end
%%
% set up soft body and logger
system = ParticleSystem();
log = Logger('test.log',0,1);
num_segments = 10;

% get binary worm fill
tgt = rgb2gray(background - first_frame);
target = process_worm(tgt);
[edges, tresh, gv, gh] = edge(target,'sobel');
skel = bwmorph(target, 'skel', Inf);
skel = imdilate(skel, ones(2));

% find edges
edge_dirs = atan2(gv, gh);
edge_dirs = edge_dirs(edge_dirs ~= 0);
[edge_row edge_col] = find(edges);

% calculate normals and find opposite edges
a_edges = [];
b_edges = [];
centerlines = [];
dist = max(max(bwdist(~target),[],1));
if(show_stuff)
    imshow(edges + skel);
    hold on;
end

mod_factor = ceil(length(edge_row)/num_segments)

for(i = 1:length(edge_row))
    if(mod(i,mod_factor) == 0)
        x1 = edge_row(i);
        y1 = edge_col(i);
        dir = atan2(gv(x1,y1), gh(x1,y1));
        
        normal = NaN;
        found_center = 0;
        for(n = 1:round(dist*2.5))
            x = round(x1 + cos(dir+pi)*n);
            y = round(y1 + sin(dir+pi)*n);
            if(isnan(normal))
                if(target(x, y) == 0)
                    normal = [x y];
                    a_edges = [a_edges Edge(x1, y1)];
                    b_edges = [b_edges Edge(x, y)];
                    if(show_ribs)
                        plot([y1 y],[x1 x],'r');
                    end
                end
            end
            if(~found_center)
                if(skel(x, y) == 1)
                    centerlines = [centerlines Edge(x, y)];
                    found_center = 1;
                end
            end
        end
        if(show_normals)
            plot([y1 y1+sin(pi+dir)*5],[x1 x1+cos(pi+dir)*5]);
        end
    end
end

if(show_stuff)
    k = waitforbuttonpress();
end    

% now sample each left/right edge pair
k = randperm(size(a_edges,2)); 
num_segments = length(a_edges);
selected_left = a_edges(1:num_segments);
selected_right = b_edges(1:num_segments);
selected_centers = centerlines(1:num_segments);

% create the mesh
for(i = 1:num_segments)
    system.num_nodes
    % create NODES and SPRINGS
    left_edge  = Node(i*3 - 2, [selected_left(i).i    selected_left(i).j],   [0 0],10, 0.5, 0);
    spine      = Node(i*3 - 1, [selected_centers(i).i selected_centers(i).j],[0 0],10, 0.5, 0);
    right_edge = Node(i*3,     [selected_right(i).i    selected_right(i).j], [0 0],10, 0.5, 0);
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
    system.num_nodes
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

if(show_node_alignment)
    hold off;
    imshow(edges);
    hold on;
end

% process
for(iteration = 1:num_ticks)
    iteration
    system.tick();
    log.error(num2str(iteration));
    for(i = 1:system.num_nodes)
        log.warning(num2str(system.NODES(i).id));
        log.warning(num2str(system.NODES(i).position));
        if(show_node_alignment)
            circle(system.NODES(i).position(1), system.NODES(i).position(2), 5);
            pause(0.1);
        end
    end
    log.note('-----------------------------');
end

% render
hold off;
imshow(edges);
hold on;

for(i = 1:system.num_nodes)
    this_node = system.NODES(i);
    circle(this_node.position(1), this_node.position(2), 3);
    log.warning(num2str(this_node.id));
    log.warning(num2str(this_node.position));
end

k = waitforbuttonpress();
%%
for(frame_num = 1:vid.NumberOfFrames)
    frame_num
    frame = imresize(read(vid,frame_num),vid_scale);
    % process image
    background = frame;
    for i = 1:3
        background(:,:,i) = roifill(frame(:,:,i),mask);
    end

    imshow(edges);
    hold on;
    % get binary worm fill
    tgt = rgb2gray(background - frame);
    target = process_worm(tgt);
    edges = edge(target);  
    [edge_row edge_col] = find(edges);    
    for(i = 1:length(edge_row))
        if(mod(i,mod_factor) == 0)
            x1 = edge_row(i);
            y1 = edge_col(i);
            dir = atan2(gv(x1,y1), gh(x1,y1));

            normal = NaN;
            for(n = 1:round(dist*2.5))
                x = round(x1 + cos(dir+pi)*n);
                y = round(y1 + sin(dir+pi)*n);
                if(isnan(normal))
                    if(target(x, y) == 0)
                        normal = [x y]
                        a_edges = [a_edges Edge(x1, y1)];
                        b_edges = [b_edges Edge(x, y)];
                        plot([y1 y],[x1 x],'r');
                    end
                end
            end
        end
    end
    
    
    for(i = 1:num_segments)
        system.NODES(i*3+2).position = a_edges(i).pos;
        system.NODES(i*3).position = b_edges(i).pos;
    end
    
    %for(i = 1:system.num_nodes)
    %    this_node = system.NODES(i);
    %    circle(this_node.position(1), this_node.position(2), 3);
    %end
    
    pause(0.01);
end