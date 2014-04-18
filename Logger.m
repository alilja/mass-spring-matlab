classdef Logger
    properties
        output_file;
        FID;
        
        screen_print; % print to screen
        file_print;   % print to file
    end
    
    methods
        function obj = Logger(file, screen_print, file_print)
            if(nargin > 0)
                obj.output_file = file;
                obj.FID = fopen(file, 'wt');
                if obj.FID < 0
                    error('Logger could not open log file.');
                end
                if(nargin > 1)
                    obj.screen_print = screen_print;
                    obj.file_print = file_print;
                end
            else
                FID = -1;
            end
        end
        
        function delete(obj)
            fclose(FID);
            FID = -1;
        end
        
        function note(obj, data)
            obj.log(data,'NTE');
        end
        
        function warning(obj, data)
            obj.log(data,'WRN');
        end
        
        function error(obj, data)
            obj.log(data,'ERR');
        end
        
        function log(obj, data, type)
            data = strcat(datestr(clock,0), ' [',type,']: ',data);
            if(nargin > 0)
                if(obj.file_print == 1)
                    fprintf(obj.FID, '%s\n', data);
                end
                if(obj.screen_print == 1)
                    disp(sprintf(data));
                end
            end
        end
        
        function obj = log_file(obj, file)
            obj.output_file = file;
            obj.FID = fopen(fullfile(tempdir, file), 'wt');
            if obj.FID < 0
                error('Logger could not open log file.');
            end
        end
    end
end
                

    