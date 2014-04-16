classdef RefValue < handle
    properties
        data = [];
    end
    
    methods
        function obj = RefValue(input_data)
            obj.data = input_data;
        end
    end
end