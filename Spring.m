classdef Spring
% just contains the rest length, stiffness, and damping of springs
    
    properties
        length;
        k;
        damp;
        attached_node_a;
        attached_node_b;
    end
    
    methods
        function obj = Spring(length, k, damp, a, b)
            obj.length = length;
            obj.k = k;
            obj.damp = damp;
            obj.attached_node_a = a;
            obj.attached_node_b = b;
        end
        
        function obj = apply()
            diff = obj.attached_node_a.position - obj.attached_node_b.position;
            distance = norm(diff);
            diff = diff/distance;

            compression = distance - obj.length;
            vel = obj.attached_node_a.velocity - obj.attached_node_b.velocity;

            force = compression * obj.k + dot(vel, diff)*obj.damp;

            obj.attached_node_b.force = obj.attached_node_b.force + diff*force;
            obj.attached_node_a.force = obj.attached_node_a.force - diff*force;
            
            % tell the nodes to update their velocity and position
            obj.attached_node_a.update;
            obj.attached_node_b.update; 
        end
    end
end