%% wip
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
                if(render == 1)
                    obj.circle(obj.NODES(i).position(1), ...
                               obj.NODES(i).position(2), 1);
                end
            end
        end          
        
        function obj = add_node(obj, node)
            obj.num_nodes = obj.num_nodes + 1;
            obj.NODES = [obj.NODES node]
        end
        
        function obj = add_spring(obj, spring)
            obj.num_springs = obj.num_springs + 1;
            obj.SPRINGS = [obj.SPRINGS spring]
        end
        
        function obj = circle(obj, x,y,r)
            %x and y are the coordinates of the center of the circle
            %r is the radius of the circle
            %0.01 is the angle step, bigger values will draw the circle faster but
            %you might notice imperfections (not very smooth)
            ang=0:0.01:2*pi; 
            xp=r*cos(ang);
            yp=r*sin(ang);
            plot(x+xp,y+yp);
        end
    end
end