classdef Node < handle
% the mass part of the system
    properties
        position;
        force;
        mass;
        velocity;
        id;
        locked;
        damp;
        attached_nodes;
    end
    
    methods
        function obj = Node(id, position, force, mass, damp, locked)
            if(nargin > 0)
                obj.position = position;
                obj.force = force;
                obj.mass = mass;
                obj.velocity = [0 0];
                obj.locked = 0;
                obj.id = id;
                obj.damp = damp;
                if(nargin > 5)
                    obj.locked = locked;
                end
                obj.attached_nodes = [];
            end
        end
        
        function obj = add_force(obj, force)
            obj.force = obj.force + force;
        end
        
        function obj = tick(obj)
            old_pos = obj.position;
            obj.velocity = obj.velocity + obj.force / obj.mass;
            obj.velocity = obj.velocity * obj.damp;
            obj.force = [0 0];
            if(obj.locked == 0) % make sure locked nodes don't move
                obj.position = obj.position + obj.velocity;
            end
            if(isnan(obj.position))
                obj.position = old_pos;
            end
        end
    end    
end