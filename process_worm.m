function target = process_worm(input_image)
    target = imerode(input_image, ones(2));
    target = imdilate(target, strel('disk',30));
    target = imclose(target,strel('disk',30));
    target = imerode(target, strel('disk',30));
    target = target > 7;
end