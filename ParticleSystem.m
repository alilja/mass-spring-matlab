classdef ParticleSystem < handle
    properties
        NODES;
        SPRINGS;
        num_nodes;
        num_springs;
        system_force;
    end
    
    methods
        function obj = ParticleSystem(obj, nodes, springs, force)
            obj.num_nodes = 0;
            obj.num_springs = 0;
            obj.system_force = [0 0];
            if(nargin > 0)
                obj.NODES = nodes;
                obj.SPRINGS = springs;
                obj.num_nodes = max(size(nodes));
                obj.num_springs = max(size(springs));
                obj.system_force = force;
            end            
        end
        
        function obj = tick(obj, render)
            for(j = 1:obj.num_springs)
                obj.SPRINGS(j).tick();
            end   

            for(i = 1:obj.num_nodes)
                obj.NODES(i).add_force(obj.system_force);
                obj.NODES(i) = obj.NODES(i).tick();
            end
        end          
        
        function obj = add_node(obj, node)
            obj.num_nodes = obj.num_nodes + 1;
            obj.NODES = [obj.NODES node];
        end
        
        function obj = add_spring(obj, spring)
            obj.num_springs = obj.num_springs + 1;
            obj.SPRINGS = [obj.SPRINGS spring];
        end
    end
end