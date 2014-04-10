classdef Node
% the mass part of the system
    properties
        position;
        force;
        mass;
        velocity;
        id;
    end
    
    methods
        function obj = Node(position, force, mass)
            obj.position = position;
            obj.force = force;
            obj.mass = mass;
            obj.velocity = [0 0];
        end
    end
end