num_frames = 10000;

num_segments = 20;
start_pos = [10 10];
width = 20;
length = 80;

step = length/num_segments;
nodes = [];
springs = [];

% create the mesh
for(i = 1:num_segments)
    % create nodes and springs
    left_edge  = Node(start_pos + [-width/2 step*i],0,10);
    spine      = Node(start_pos + [0 step*i],0,10);
    right_edge = Node(start_pos + [width/2 step*i],0,10);
    % a node is spine %
    k = 3
    damp = 0.5
    left_spring  = Spring(width/2, k, damp, spine, left_edge);
    right_spring = Spring(width/2, k, damp, spine, left_edge);
    if(i > 1)
        % a is previous node
        left_connector  = Spring(step, k, damp, nodes((i-1)*3 - 2), left_edge);
        spine_connector = Spring(step, k, damp, nodes((i-1)*3 - 1), spine);
        right_connector = Spring(step, k, damp, nodes((i-1)*3), right_edge);
    end
    
    % populate lists
    nodes = [nodes left_edge spine right_edge];
    springs = [springs left_spring right_spring]
    if(i > 1)
        springs = [springs left_connector spine_connector right_connector]
    end
end

node_len   = max(size(nodes));
spring_len = max(size(springs))

figure; hold on;

for(frame_num = 1:num_frames)
    frame_num
    k = waitforbuttonpress();
    % tick
    nodes(1).force = 2;
    
    for(j = 1:spring_len)
        springs(j).apply();
    end   
    
    for(i = 1:node_len)
        nodes(i) = nodes(i).update();
        circle(nodes(i).position(1), nodes(i).position(2), 1);
    end
    
end
