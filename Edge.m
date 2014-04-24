% i wish matlab had structs

classdef Edge
    properties
        pos;
    end
    
    methods
        function obj = Edge(x, y)
            obj.pos = [y x];
        end
        
        function num = i(obj)
            num = obj.pos(1);
        end
        
        function num = j(obj)
            num = obj.pos(2);
        end
    end
end