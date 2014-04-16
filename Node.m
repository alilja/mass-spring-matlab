classdef Node < handle
% the mass part of the system
    properties
        position;
        force;
        mass;
        velocity;
        id;
        locked;
    end
    
    methods
        function obj = Node(id, position, force, mass, locked)
            if(nargin > 0)
                obj.position = position;
                obj.force = force;
                obj.mass = mass;
                obj.velocity = [0 0];
                obj.locked = 0;
                obj.id = id;
                if(nargin > 4)
                    obj.locked = locked;
                end
            end
        end
        
        function obj = update(obj)
            obj.velocity = obj.velocity + obj.force / obj.mass;
            if(obj.locked == 0) % make sure locked nodes don't move
                obj.position = obj.position + obj.velocity;
            end
        end
    end
    
end