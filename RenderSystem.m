classdef RenderSystem    
    properties(GetAccess = 'public', SetAccess = 'private')
        dimensions;
        frame;
        scale;
        field;
    end
    
    
    methods
        function obj = RenderSystem(dimensions, scale)
            if(nargin > 0)
                obj.dimensions = dimensions;
                obj.scale = scale;
                
                obj.field = zeros(obj.dimensions)
            end
            obj.frame = 1;
        end
        
        function obj = add_element(obj, pos, scale)
            obj.field(round(pos - scale/2):pos + round(pos + scale/2),...
                round(pos - scale/2):pos + round(pos + scale/2)) = 1;
        end
        
        function obj = display(obj)
            imshow(obj.field);
            % obj.field = zeros(obj.dimensions);
        end
    end
end
            