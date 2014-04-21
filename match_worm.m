% 1. process image
% 2. walk image from left -> right and find edges
% 2a. store left and right edges in separate vectors
% 3. use those edge coordinates to populate mesh, going from the top down
% 4. run mass-spring
% 5. ???
% 6. profit

num_segments = 20;
start_pos = [10 10];
width = 20;
length = 80;

step = length/num_segments;


system = ParticleSystem();

% create the mesh
for(i = 1:num_segments)
    % create NODES and SPRINGS
    left_edge  = Node(i*3 - 2, start_pos + [-width/2+rand*5 step*i],[0 0],10,0.5,1);
    spine      = Node(i*3 - 1, start_pos + [0 step*i],[0 0],10, 0.5);
    right_edge = Node(i*3, start_pos + [width/2-rand*5 step*i],[0 0],10, 0.5, 1);
    % a node is spine %
    k = 3;
    damp = 0.5;
    spring_id_base = system.num_springs;
    left_spring  = Spring(spring_id_base + 1, width/2, k, damp, spine, left_edge);
    right_spring = Spring(spring_id_base + 2, width/2, k, damp, spine, right_edge);
    if(i > 1)
        % a is previous node
        left_connector  = Spring(spring_id_base + 3, step, k, damp, system.NODES((i-1)*3 - 2), left_edge);
        spine_connector = Spring(spring_id_base + 4, step, k, damp, system.NODES((i-1)*3 - 1), spine);
        right_connector = Spring(spring_id_base + 5, step, k, damp, system.NODES((i-1)*3), right_edge);
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

%figure; hold on;
% process image
I = imread('test.png');
I = im2bw(I);
edges = edge(I,'canny');

% find edges
% THERE HAS TO BE A BETTER WAY TO DO THIS
image_size = size(edges);
left_found = 0;
left_edges = [];
right_edges = [];
for(row = 1:image_size(1))
    for(col = 1:image_size(2))
        if(edges(row, col) == 1)
            if(left_found == 0)
                left_edges = [left_edges Edge(row, col)];
                left_found = 1;
            else
                right_edges = [right_edges Edge(row, col)];
                left_found = 0;
            end
        end
    end
end

% now randomly sample each left/right edge pair and use them to create the
% mesh

%%% IT WILL BE DONE %%%

% process
%for(iteration = 1:30)
%    system.tick();
%end

% render
%circle(system.NODES(i).position(1), system.NODES(i).position(2), 1);
