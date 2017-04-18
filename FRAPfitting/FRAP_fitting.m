filename = 'Z:\FRAP data\160626\Control-gel1_GelEdge_3SOI_010.nd2';

mydata = bfopen(filename);
file_size = size(mydata{1,1},1);
frames = file_size/2; %divide by the number of color channels (2)
display(['Video has been imported. It has ', num2str(frames), ' frames.'])
clear file_size

ListOfImages = mydata{1,1};
GreenImages = ListOfImages(1:2:length(ListOfImages));
RedImages = ListOfImages(2:2:length(ListOfImages));
clear ListOfImages

mask = imread('Z:\FRAP data\160626\resaved for FRAP toolbox\Control-gel1_GelEdge_3SOI_010_copy_ROI.tif');
xscale = 1.11;
area3 = sum(sum(mask));
radius = xscale*sqrt(area3/(3*pi()));
clear area3

%%
imshow(mask);
h1 = imrect;
h2 = imrect;
h3 = imrect;

roi = {h1.createMask, h2.createMask, h3.createMask};
clear h1 h2 h3;
close all

%%
for n=1:3
    for t=1:length(RedImages)
        gcounts(n,t) = sum(sum(uint16(roi{n}).*uint16(mask).*GreenImages{t}));
        rcounts(n,t) = sum(sum(uint16(roi{n}).*uint16(mask).*RedImages{t}));
    end
end
clear n t

%% test plot
i = 3;
plot(gcounts(i,:)/gcounts(i,1),'go','MarkerFaceColor','g')
hold on
plot(rcounts(i,:)/rcounts(i,1),'ro','MarkerFaceColor','r')
xlabel('Frames');
ylabel('Normed intensity');
title('FRAP curves')
legend('Green','Red', 'Location','northeast');
annotation('textbox', [0.65,0.3,0.1,0.1],'String',...
    {['Init. green ' num2str(gcounts(i,1))],['Init. red ' num2str(rcounts(i,1))]})
hold off
clear i

%%
time = [((1:10)-1) (4*(1:30)+6)];
%%
for i=1:3
    g = gcounts(i,11:end)/gcounts(i,1);
    r = rcounts(i,11:end)/rcounts(i,1);
    
    gy(i) = g(1);
    ry(i) = r(1);
    
    g = g-g(1);
    r = r-r(1);
    
     [resg, gofg] = FRAPfit(time,g, 'g--');
     ag(i) = resg.a;
%     %cg(i) = resg.c;
%     %dg(i) = resg.d;
     taug(i) = resg.tau;
    
    [resr, gofr] = FRAPfit(time,r, 'k--');
    ar(i) = resr.a;
    %cr(i) = resr.c;
    %dr(i) = resr.d;
    taur(i) = resr.tau;
end
clear resg resr gofg gofr
 %%
% scale = [0; 0.03];
% 
% % Make a composite falsecolor image of the final green and red frames so
% % that user can see both edges of the gel.
% finalGreen = im2double(GreenImages{1,end});
% finalGreen = imadjust(finalGreen,scale, [0; 1] );
% 
% firstGreen = im2double(GreenImages{1,1});
% firstGreen = imadjust(firstGreen,scale, [0; 1] );
% 
% finalRed = im2double(RedImages{1,end});
% finalRed = imadjust(finalRed,scale, [0; 1] );
% 
% firstRed = im2double(RedImages{1,1});
% firstRed = imadjust(firstRed,scale, [0; 1] );
% 
% %composite = imfuse(firstRed, finalRed, 'falsecolor');
% imshow(composite);
% 
% h = imrect;
% roi = h.createMask;
% %h = imdistline;

%%
% counts = zeros(2,length(RedImages));
% for i=1:length(RedImages)
%     counts(1,i) = sum(sum(uint16(roi).*GreenImages{1,i}));
%     counts(2,i) = sum(sum(uint16(roi).*RedImages{1,i}));
% end
% 
% %%
% plot(counts(1,:)/counts(1,1),'go','MarkerFaceColor','g')
% hold on
% plot(counts(2,:)/counts(2,1),'ro','MarkerFaceColor','r')
% xlabel('Frames');
% ylabel('Normed intensity');
% title('FRAP curves')
% legend('Green','Red', 'Location','northeast');
% annotation('textbox', [0.65,0.3,0.1,0.1],'String',...
%     {['Init. green ' num2str(counts(1,1))],['Init. red ' num2str(counts(2,1))]})
% hold off
% 
% %%
% frames = 1:length(counts(1,11:end));
% g = counts(1,11:end)/counts(1,1);
% r = counts(2,11:end)/counts(2,1);
% 
% g = g-g(1);
% r = r - r(1);
% 
% %%
% [resultg, gofg] = FRAPfit(frames, g, 'g--');
% [resultr, gofr] = FRAPfit(frames, r, 'r--');
% 
% %%
% mask = imread('Z:\FRAP data\160626\resaved for FRAP toolbox\Control-gel1_GelEdge_3SOI_010_copy_ROI.tif');
% xscale = 1.11;
% %%
% imshow(mask);
% area3 = sum(sum(mask));
% radius = xscale*sqrt(area3/(3*pi()));