% i wish matlab had structs

classdef Edge
    properties
        i
        j
    end
    
    methods
        function obj = Edge(i, j)
            obj.i = i;
            obj.j = j;
        end
    end
end