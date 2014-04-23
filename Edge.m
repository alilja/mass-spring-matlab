% i wish matlab had structs

classdef Edge
    properties
        i
        j
    end
    
    methods
        function obj = Edge(x, y)
            obj.i = y;
            obj.j = x;
        end
    end
end