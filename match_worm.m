% 1. add lines to mesh
% best way to do above is with nodes knowing about which nodes they're
% attached to

% 2. have two endpoint spine nodes that connect to edge nodes in next segment
% 3. switch from random sampling to consistent intervals
% 4. test on worm videos

num_segments = 10;
num_ticks = 20;

system = ParticleSystem();
log = Logger('test.log',0,1);

% process image
first_frame = imresize(read(vid,50),0.66);
mask = roipoly(first_frame);
background = first_frame;
for i = 1:3
    background(:,:,i) = roifill(first_frame(:,:,i),mask);
end
%%
% find worm edges
target = rgb2gray(background - first_frame);
target = imerode(target, ones(2));
target = imdilate(target, strel('disk',20));
target = imclose(target,strel('disk',20));
target = imerode(target, strel('disk',20));
target = target > 10;
[edges, tresh, gv, gh] = edge(target,'sobel');
skel = bwmorph(target, 'skel', Inf); % bwmorph(~target,'endpoints');
[skel_x skel_y] = imgradientxy(skel);

% find edges
edge_dirs = atan2(gv, gh);
edge_dirs = edge_dirs(edge_dirs ~= 0);
[edge_row edge_col] = find(edges);

% calculate normals and fine opposite edges
a_edges = [];
b_edges = [];
centerlines = [];
dist = max(max(bwdist(~target),[],1))
imshow(first_frame);
k = waitforbuttonpress;
imshow(skel_x);
hold on;
for(i = 1:round(max(size(edge_row))))
    if(mod(i,2) == 0)
        x = edge_row(i);
        y = edge_col(i);
        dir = atan2(gv(x, y), gh(x,y));
        a_edges = [a_edges Edge(y, x)];
        b_edges = [b_edges Edge(y+sin(pi+dir)*2*dist, x+cos(pi+dir)*2*dist)];
        plot([y y+sin(pi+dir)*dist*0.5],[x x+cos(pi+dir)*dist*0.5]);
        centerlines = [centerlines Edge(y+sin(dir)*dist, x+cos(dir)*dist)];
    end
end
if(0)
% now randomly sample each left/right edge pair
k = randperm(size(a_edges,2)); 
selected_left = a_edges(k(1:num_segments));
selected_right = b_edges(k(1:num_segments));
selected_centers = centerlines(k(1:num_segments));

% create the mesh
step = length/num_segments;
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

imshow(edges);
hold on;

% process
for(iteration = 1:num_ticks)
    iteration
    system.tick();
    log.error(num2str(iteration));
    for(i = 1:system.num_nodes)
        log.warning(num2str(system.NODES(i).id));
        log.warning(num2str(system.NODES(i).position));
        circle(system.NODES(i).position(1), system.NODES(i).position(2), 5);
    end
    pause(0.1);
    log.note('');
    log.note('');
    log.note('');
    log.note('');
end

hold off;
imshow(edges);
hold on;
log.note(sprintf('\n\n'));
for(i = 1:system.num_nodes-1)
    circle(system.NODES(i).position(1), system.NODES(i).position(2), 5);
    log.warning(num2str(system.NODES(i).id));
    log.warning(num2str(system.NODES(i).position));
    if(mod(i+1,3))
        plot([system.NODES(i).position(1) system.NODES(i+1).position(1)],[system.NODES(i).position(2) system.NODES(i+1).position(2)]);
    end
end
end