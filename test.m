clc
close all
clear all
%first read in the video
[file,path] = uigetfile('*.mp4');
filename = [path,file];
vid = VideoReader(filename);
%%
%display the first frame to perform segmentation
start_frame = 100;
first_frame = read(vid,start_frame);
mask = roipoly(first_frame);
background = first_frame;
for i = 1:3
    background(:,:,i) = roifill(first_frame(:,:,i),mask);
end
%%
%use "optical flow" to decide which sections of the worm need to be updated
flow_image = zeros(size(first_frame,1),size(first_frame,2),3);
average_width=50;
for i = start_frame:start_frame+30;
    %find binary worm for the previous frame
    sub = uint8(abs(double(background) - double(first_frame)));
    sub = rgb2gray(sub);
    bin1 = sub > 10;
    bin1=~bwareaopen(~bin1,50,4);
    
    %fine binary worm for the current frame
    second_frame = read(vid,i);
    sub2 = uint8(abs(double(background) - double(second_frame)));
    flow_image = double(second_frame)/255;
    sub2 = rgb2gray(sub2);
    bin2 = sub2 > 10;
    bin2=~bwareaopen(~bin2,50);
    
    %develop skeleton for the current frame
    dist_trans1 = bwdist(~imfill(bin2,'holes'));
    dist_trans = bwdist(~bin2);
    dist_trans1 = (dist_trans1>average_width*.8)&(dist_trans1<average_width*1.5);
    dist_trans = bwmorph(bwmorph((dist_trans>average_width*.8)&(dist_trans<average_width*1.5),'thin','inf'),'dilate',1);
    dist_trans = dist_trans|dist_trans1;
    
    skel = bwmorph(dist_trans,'thin',inf);
end