vid = VideoReader('shisto.avi');
first_frame = imresize(read(vid,50),0.66);
mask = roipoly(first_frame);
background = first_frame;
for i = 1:3
    background(:,:,i) = roifill(first_frame(:,:,i),mask);
end
%%
%have user highlight centerline
%edges = edge(rgb2gray(background - first_frame));
target = rgb2gray(background - first_frame);
target = imerode(target, ones(2));
target = imdilate(target, strel('disk',25));

target = imerode(target, strel('disk',25));
target = imclose(target,strel('disk',25));
target = target > 5;
[edges, tresh, gv, gh] = edge(target,'sobel');
edge_dirs = atan2(gv, gh);
edge_dirs = edge_dirs(edge_dirs ~= 0);
[edge_row edge_col] = find(edges);

dist = max(max(bwdist(~target),[],1));

%[bw_rows,bw_cols] =find(edges==1);
%bw_rowcol = [bw_rows bw_cols];
%bw_rowcol(:,1) = size(target,1) - bw_rowcol(:,1); % To offset for the MATLAB's terminology of showing height on graphs
%intersection_pts = [];
imshow(target);
hold on;

% walk the line out, the first time you find a pixel that isn't white,
% that's the intersection point
% not elegant
% not fast
% BUT IT WILL WORK

for(i = 1:max(size(edge_row)))
    if(mod(i,5) == 0)
        x1 = edge_row(i);
        y1 = edge_col(i);
        dir = atan2(gv(x1,y1), gh(x1,y1));
        
        normal = NaN;
        for(n = 1:round(dist*2))
            x = round(x1 + cos(dir+pi)*n);
            y = round(y1 + sin(dir+pi)*n);
            if(isnan(normal))
                if(target(x, y) == 0)
                    normal = [x y]
                    plot([y1 y],[x1 x],'r')
                end
            end
        end
    end
end