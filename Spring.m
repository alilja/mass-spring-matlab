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
            end
        end
        
        function obj = apply(obj)
            diff = obj.attached_node_a.position - obj.attached_node_b.position
            distance = norm(diff)
            diff = diff/distance

            compression = distance - obj.length
            vel = obj.attached_node_a.velocity - obj.attached_node_b.velocity

            force = compression * obj.k + dot(vel, diff)*obj.damp

            obj.attached_node_a.force = obj.attached_node_a.force - diff*force;
            obj.attached_node_b.force = obj.attached_node_b.force + diff*force
            
            forces = [obj.node_a_id obj.node_b_id  diff*force]
            
            % tell the nodes to update their velocity and position
        end
    end
end