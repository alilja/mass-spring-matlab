num_frames = 500;

num_segments = 20;
start_pos = [10 10];
width = 20;
length = 80;

step = length/num_segments;
NODES = [];
SPRINGS = [];

% create the mesh
%for(i = 1:num_segments)
%    % create NODES and SPRINGS
%    left_edge  = Node(i*3 - 2, start_pos + [-width/2 step*i],0,10);
%    spine      = Node(i*3 - 1, start_pos + [0 step*i],0,10);
%    right_edge = Node(i*3, start_pos + [width/2 step*i],0,10);
%    % a node is spine %
%    k = 3
%    damp = 0.5
%    spring_id_base = max(size(SPRINGS));
%    left_spring  = Spring(spring_id_base + 1, width/2, k, damp, spine, left_edge);
%    right_spring = Spring(spring_id_base + 2, width/2, k, damp, spine, right_edge);
%    if(i > 1)
%        % a is previous node
%        left_connector  = Spring(spring_id_base + 3, step, k, damp, NODES((i-1)*3 - 2), left_edge);
%        spine_connector = Spring(spring_id_base + 4, step, k, damp, NODES((i-1)*3 - 1), spine);
%        right_connector = Spring(spring_id_base + 5, step, k, damp, NODES((i-1)*3), right_edge);
%    end
%    
%   % populate lists
%    NODES = [NODES left_edge spine right_edge];
%    SPRINGS = [SPRINGS left_spring right_spring]
%    if(i > 1)
%        SPRINGS = [SPRINGS left_connector spine_connector right_connector]
%    end
%end

% simple test w/ rope
for(x = 1:8)      
    NODES = [NODES Node(x, [0 2+x*5], [0 0], 10, 0.5)]; %#ok<AGROW>
    if(x > 1)
        SPRINGS = [SPRINGS Spring(x-1, 5, 3, 0.5, NODES(x-1), NODES(x))];
    end
end

NODES(8).position = NODES(8).position + [30 0];
NODES(1).locked = 1;

node_len   = max(size(NODES));
spring_len = max(size(SPRINGS))

figure; hold on;

for(frame_num = 1:num_frames)
    frame_num
    %k = waitforbuttonpress();
    pause(0.1)
    % tick    
    for(j = 1:spring_len)
        SPRINGS(j).tick();
    end   
    
    for(i = 1:node_len)
        NODES(i).add_force([0 9.8]);
        NODES(i) = NODES(i).tick();
        circle(NODES(i).position(1), NODES(i).position(2), 1);
    end
end
