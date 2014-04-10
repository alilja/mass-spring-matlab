clear;
r = RenderSystem([100 100], 1);
pos = [40 0]
for(i = 1:600)
    pos(2) = pos(2) + 1/3
    r.add_element(pos, 10);
    r.display
    i
end