classdef Spring < handle
% just contains the rest length, stiffness, and damping of springs
    
    properties
        length;
        k;
        damp;
        attached_node_a;
        attached_node_b;
        node_a_id;
        node_b_id;
        id;
    end
    
    methods
        function obj = Spring(id, length, k, damp, a, b)
            if(nargin > 0)
                obj.length = length;
                obj.k = k;
                obj.damp = damp;
                obj.id = id;
                obj.attached_node_a = a;
                obj.attached_node_b = b;

                obj.node_a_id = a.id;
                obj.node_b_id = b.id;
                
                a.attached_nodes = [a.attached_nodes b];
                b.attached_nodes = [b.attached_nodes a];
            end
        end
        
        function obj = tick(obj)
            diff = round(obj.attached_node_b.position - obj.attached_node_a.position);
            distance = norm(diff);
            diff = diff/distance;

            compression = obj.length - distance*obj.damp;
            vel = round(obj.attached_node_b.velocity - obj.attached_node_a.velocity);

            force = diff*(obj.k * compression + dot(diff, vel) * obj.damp);  
            
            % tell the nodes to update their velocity and position
            obj.attached_node_a.add_force(force);
            obj.attached_node_b.add_force(-force);
        end
    end
end