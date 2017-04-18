
file = cell(1,9);
file{1} = 'Z:\FRAP data\160609\FRAPsequence.nd2';
for i=2:9
    file{i} = ['Z:\FRAP data\160609\FRAPsequence' num2str(i) '.nd2'];
end
clear i

%%
mydata = bfopen(file{1});
file_size = size(mydata{1,1},1);
frames = file_size/2; %divide by the number of color channels (2)
display(['Video has been imported. It has ', num2str(frames), ' frames.'])

ListOfImages = mydata{1,1};
GreenImages = ListOfImages(1:2:length(ListOfImages));
RedImages = ListOfImages(2:2:length(ListOfImages));

scale = [0; 0.03];

finalGreen = im2double(GreenImages{1,end});
finalGreen = imadjust(finalGreen,scale, [0; 1] );

firstGreen = im2double(GreenImages{1,1});
firstGreen = imadjust(firstGreen,scale, [0; 1] );

finalRed = im2double(RedImages{1,end});
finalRed = imadjust(finalRed,scale, [0; 1] );

firstRed = im2double(RedImages{1,1});
firstRed = imadjust(firstRed,scale, [0; 1] );

composite = imfuse(firstRed, finalRed, 'falsecolor');
imshow(composite);

%h = imrect;
h= imdistline;
%roi = h.createMask;

gcounts = zeros(length(file),length(RedImages));
rcounts = zeros(length(file),length(RedImages));
%%
for i=1:length(file)
    close all
    
    mydata = bfopen(file{i});
    file_size = size(mydata{1,1},1);
    frames = file_size/2; %divide by the number of color channels (2)
    display(['Video has been imported. It has ', num2str(frames), ' frames.'])

    ListOfImages = mydata{1,1};
    GreenImages = ListOfImages(1:2:length(ListOfImages));
    RedImages = ListOfImages(2:2:length(ListOfImages));
    
    for j=1:length(RedImages)
        gcounts(i,j) = sum(sum(uint16(roi).*GreenImages{1,j}));
        rcounts(i,j) = sum(sum(uint16(roi).*RedImages{1,j}));
    end
end
clear i j ListOfImages RedImages GreenImages mydata file_size frames h
clear firstRed finalRed firstGreen finalGreen composite scale

%% test plot
plot(gcounts(1,:)/gcounts(1,1),'go','MarkerFaceColor','g')
hold on
plot(rcounts(1,:)/rcounts(1,1),'ro','MarkerFaceColor','r')
xlabel('Frames');
ylabel('Normed intensity');
title('FRAP curves')
legend('Green','Red', 'Location','northeast');
annotation('textbox', [0.65,0.3,0.1,0.1],'String',...
    {['Init. green ' num2str(gcounts(1,1))],['Init. red ' num2str(rcounts(1,1))]})
hold off

%% in seconds
time = 4*(1:50)-4;
pos1 = 500*(1:6)-500;
pos = [pos1 3500 4500 5500]/1000;
clear pos1

%%
for i=1:3
    g = gcounts(i,6:end)/gcounts(i,1);
    r = rcounts(i,6:end)/rcounts(i,1);
    
    gy(i) = g(1);
    ry(i) = r(1);
    
    g = g-g(1);
    r = r-r(1);
    
%     [resg, gofg] = FRAPfit(time,g, 'g--');
%     ag(i) = resg.a;
%     %cg(i) = resg.c;
%     %dg(i) = resg.d;
%     taug(i) = resg.tau;
    
    [resr, gofr] = FRAPfit(time,r, 'k--');
    ar(i) = resr.a;
    %cr(i) = resr.c;
    dr(i) = resr.d;
    taur(i) = resr.tau;
end
clear resg resr gofg gofr

%% plotsf
close all
figure

subplot(2,2,1)
plot(pos,taug,'go','MarkerFaceColor','g')
hold all
title('Recovery lifetime (s)')
plot(pos(4:end),taur(4:end),'ro','MarkerFaceColor','r')
plot(pos(2:3),taur(2:3),'ro')

subplot(2,2,2)
plot(pos,gy,'go','MarkerFaceColor','g')
hold all
title('Frac. post-bleach')
plot(pos,ry,'ro','MarkerFaceColor','r')

subplot(2,2,3)
plot(pos,ag+gy,'go','MarkerFaceColor','g')
hold all
title('Frac. recovered')
plot(pos(2:end),ar(2:end)+ry(2:end),'ro','MarkerFaceColor','r')
xlabel('Position (mm)');

subplot(2,2,4)
plot(pos,Dg,'go','MarkerFaceColor','g')
hold all
title('D (um^2/s)')
plot(pos(4:end),Dr(4:end),'ro','MarkerFaceColor','r')
xlabel('Position (mm)');
%%
subplot(2,2,4)
plot(pos,dr,'ro','MarkerFaceColor','r')
hold all
title('Bleaching rate (per s)')
xlabel('Position (mm)');

%%
for i=1:length(file)
    Dg(i) = (0.224*(96*0.25)^2)/(taug(i)*log(2));
    Dr(i) = (0.224*(96*0.25)^2)/(taur(i)*log(2));
end