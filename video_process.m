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
skel = bwmorph(bwmorph(target, 'skel', Inf),'endpoints');
imshow(target);
k = waitforbuttonpress();
imshow(skel);