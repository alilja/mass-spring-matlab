% i wish matlab had structs

classdef Edge
    properties
        x
        y
    end
    
    methods
        function obj = Edge(x, y)
            obj.x = x;
            obj.y = y;
        end
    end
end