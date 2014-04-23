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
show_normals = 0;        % show edge normals
show_ribs = 0;           % show node placement ribs
show_node_alignment = 0; % show nodes during each tick of model

% Video Options
vid = VideoReader('shisto.avi');
start_frame = 50;
vid_scale = 0.66;


show_stuff = show_normals + show_ribs + show_node_alignment;

system = ParticleSystem();
log = Logger('test.log',0,1);

% process image
first_frame = imresize(read(vid,start_frame),vid_scale);
mask = roipoly(first_frame);
background = first_frame;
for i = 1:3
    background(:,:,i) = roifill(first_frame(:,:,i),mask);
end
%%
% get binary worm fill
target = rgb2gray(background - first_frame);
target = imerode(target, ones(2));
target = imdilate(target, strel('disk',20));
target = imclose(target,strel('disk',20));
target = imerode(target, strel('disk',20));
target = target > 10;
[edges, tresh, gv, gh] = edge(target,'sobel');
skel = bwmorph(target, 'skel', Inf); % bwmorph(~target,'endpoints');

% find edges
edge_dirs = atan2(gv, gh);
edge_dirs = edge_dirs(edge_dirs ~= 0);
[edge_row edge_col] = find(edges);

% calculate normals and fine opposite edges
a_edges = [];
b_edges = [];
centerlines = [];
dist = max(max(bwdist(~target),[],1));
if(show_stuff)
    imshow(edges);
    hold on;
end

mod_factor = floor((length(edge_row)/num_segments)/2)

for(i = 1:length(edge_row))
    if(mod(i,mod_factor) == 0)
        x1 = edge_row(i);
        y1 = edge_col(i);
        dir = atan2(gv(x1,y1), gh(x1,y1));
        
        if(show_normals)
            plot([y1 y1+sin(pi+dir)*5],[x1 x1+cos(pi+dir)*5]);
        end
        
        normal = NaN;
        for(n = 1:round(dist*2.5))
            x = round(x1 + cos(dir+pi)*n);
            y = round(y1 + sin(dir+pi)*n);
            if(isnan(normal))
                if(target(x, y) == 0)
                    normal = [x y];
                    a_edges = [a_edges Edge(x, y)];
                    b_edges = [b_edges Edge(x1, y1)];
                    centerlines = [centerlines Edge(x1 + cos(dir+pi)*dist, ...
                                    y1 + sin(dir+pi)*dist)];
                    if(show_ribs)
                        plot([y1 y],[x1 x],'r');
                    end
                end
            end
        end
    end
end

if(show_stuff)
    k = waitforbuttonpress();
end    

% now randomly sample each left/right edge pair
sort_list = [a_edges; b_edges; centerlines;];
sort_list = sort(sort_list,2);
selected_left    = sort_list(1, 1:num_segments);
selected_right   = sort_list(2, 1:num_segments);
selected_centers = sort_list(3, 1:num_segments);

% create the mesh
for(i = 1:num_segments)
    % create NODES and SPRINGS
    left_edge  = Node(i*3 - 2, [selected_left(i).i selected_left(i).j],[0 0],10,0.5,1);
    spine      = Node(i*3 - 1, [selected_centers(i).i selected_centers(i).j],[0 0],10, 0.5);
    right_edge = Node(i*3, [selected_right(i).i selected_right(i).j],[0 0],10, 0.5, 1);
    % a node is spine %
    k = 0.5;
    damp = 0.1;
    spring_id_base = system.num_springs;
    left_spring  = Spring(spring_id_base + 1, 2, k, damp, spine, left_edge);
    right_spring = Spring(spring_id_base + 2, 2, k, damp, spine, right_edge);
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
        end
    end
    pause(0.1);
    log.note('-----------------------------');
end

% render
hold off;
imshow(edges);
hold on;
for(i = 1:system.num_nodes)
    this_node = system.NODES(i);
    circle(this_node.position(1), this_node.position(2), 5);
    log.warning(num2str(this_node.id));
    log.warning(num2str(this_node.position));
    for(n = 1:length(this_node.attached_nodes))
        plot([this_node.position(1) this_node.attached_nodes(n).position(1)],...
             [this_node.position(2) this_node.attached_nodes(n).position(2)]);
    end
end