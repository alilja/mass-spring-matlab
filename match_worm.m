% add lines to mesh
% figure out disappearing spine issue

num_segments = 50;
start_pos = [0 0];
width = 20;
length = 80;

system = ParticleSystem();
log = Logger('test.log',0,1);

%figure; hold on;
% process image
I = imread('test2.png');
I = im2bw(I);
[edges, tresh, gv, gh] = edge(I,'sobel');

edge_dirs = atan2(gv, gh);
edge_dirs = edge_dirs(edge_dirs ~= 0);
[edge_row edge_col] = find(edges);
a_edges = [];
b_edges = [];
centerlines = [];
dist = max(max(bwdist(I),[],1));

for(i = 1:max(size(edge_row)))
    if(mod(i,5) == 0)
        x = edge_row(i);
        y = edge_col(i);
        dir = atan2(gv(x, y), gh(x,y));
        a_edges = [a_edges Edge(y, x)];
        b_edges = [b_edges Edge(y+sin(dir)*2*dist, x+cos(dir)*2*dist)];
        centerlines = [centerlines Edge(y+sin(dir)*dist, x+cos(dir)*dist)];
    end
end

% now randomly sample each left/right edge pair
k = randperm(size(a_edges,2)); 
selected_left = a_edges(k(1:num_segments));
selected_right = b_edges(k(1:num_segments));
selected_centers = centerlines(k(1:num_segments));

% create the mesh
step = length/num_segments;
for(i = 1:num_segments)
    % create NODES and SPRINGS
    left_edge  = Node(i*3 - 2, start_pos + [selected_left(i).i selected_left(i).j],[0 0],10,0.5,1);
    spine      = Node(i*3 - 1, start_pos + [selected_centers(i).i selected_centers(i).j],[0 0],10, 0.5);
    right_edge = Node(i*3, start_pos + [selected_right(i).i selected_right(i).j],[0 0],10, 0.5, 1);
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
for(iteration = 1:20)
    iteration
    system.tick();
    log.error(num2str(iteration));
    %pause(0.1);
    for(i = 1:system.num_nodes)
    %    circle(system.NODES(i).position(1), system.NODES(i).position(2), 5);
            log.warning(num2str(system.NODES(i).id));
            log.warning(num2str(system.NODES(i).position));
       
    end
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
    
    plot([system.NODES(i).position(1) system.NODES(i+1).position(1) ...
          system.NODES(i).position(2) system.NODES(i+1).position(2)]);
end
