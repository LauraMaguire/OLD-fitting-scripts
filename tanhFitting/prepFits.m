%%
of = [15,16,23,24,25,26,28,29,31,33,34,36,38,50];

%%
oflist = cell(1,length(of));
oflist{1,1} = data{1,15};
oflist{1,2} = data{1,16};
% 3 is 10 mg/mL SSSG
oflist{1,3} = data{1,23};
oflist{1,4} = data{1,24};
oflist{1,5} = data{1,25};
oflist{1,6} = data{1,26};
oflist{1,7} = data{1,28};
oflist{1,8} = data{1,29};
oflist{1,9} = data{1,31};
oflist{1,10} = data{1,33};
oflist{1,11} = data{1,34};
% 12 is 1 mg/mL FSFG
oflist{1,12} = data{1,36};
% 13 is 5 mg/mL FSFG
oflist{1,13} = data{1,38};

%%
oflist{1,14} = data{1,50};

%%
leg{1} = '1/7/16';
leg{2} = '1/8/16';
leg{3} = 'SSSG 1/18/16';
leg{4} = '1/24/16';
leg{5} = '1/25/16';
leg{6} = '1/26/16';
leg{7} = '1/28/16';
leg{8} = '2/01/16';
leg{9} = '48 hr 2/17/16';
leg{10} = '24 hr 3/18/16';
leg{11} = '24 hr no 2';
leg{12} = '1mg/mL';
leg{13} = '5 mg/mL';
leg{14} = 'presoaked';

%% ONLY RUN ONCE
oflist{3}.kymo_green=fliplr(oflist{3}.kymo_green);
oflist{3}.kymo_red=fliplr(oflist{3}.kymo_red);

oflist{4}.kymo_green=fliplr(oflist{4}.kymo_green);
oflist{4}.kymo_red=fliplr(oflist{4}.kymo_red);

oflist{5}.kymo_green=fliplr(oflist{5}.kymo_green);
oflist{5}.kymo_red=fliplr(oflist{5}.kymo_red);

%%

cutoff = ones(2,length(of));

cutoff(1,1) = 144;
cutoff(2,1) = 125;

cutoff(1,2) = 213;
cutoff(2,2) = 180;

cutoff(1,3) = 260;
cutoff(2,3) = 260;

cutoff(1,4) = 300;
cutoff(2,4) = 280;

cutoff(1,5) = 87;
cutoff(2,5) = 67;

cutoff(1,6) = 90;
cutoff(2,6) = 75;

cutoff(1,7) = 306;
cutoff(2,7) = 275;

cutoff(1,8) = 141;
cutoff(2,8) = 120;

cutoff(1,9) = 270;% good until frame 1000 or so
cutoff(2,9) = 220;

cutoff(1,10) = 201;
cutoff(2,10) = 180;

cutoff(1,11) = 146;
cutoff(2,11) = 126;

cutoff(1,12) = 62;
cutoff(2,12) = 62;

cutoff(1,13) = 15;
cutoff(2,13) = 35;

%%
cutoff(1,14) = 160;
cutoff(2,14) = 130;

%%
for i =14%:length(of)
    oflist{i}.tgp = oflist{i}.pos(cutoff(1,i):end);
    oflist{i}.trp = oflist{i}.pos(cutoff(2,i):end);
    oflist{i}.tgk = oflist{i}.kymo_green(:,cutoff(1,i):end);
    oflist{i}.trk = oflist{i}.kymo_red(:,cutoff(2,i):end);
end
%%
index = 14;
plot(oflist{index}.tgk(end,:),'b-')
hold all
plot(oflist{index}.trk(end,:),'r-')

%%
for i =14%:length(of)
    oflist{i}.tgp = oflist{i}.tgp - oflist{i}.tgp(1);
    oflist{i}.trp = oflist{i}.trp - oflist{i}.trp(1);
end

for i=14:length(of)
    for j=1:size(oflist{i}.tgk,1)
        [M,I] = max(oflist{i}.tgk(j,:));
        [M2,I2] = max(oflist{i}.trk(j,:));
        oflist{i}.tgk(j,:) = oflist{i}.tgk(j,:)/oflist{i}.tgk(j,1);
        oflist{i}.trk(j,:) = oflist{i}.trk(j,:)/oflist{i}.trk(j,1);
        for k=1:length(oflist{i}.tgk(j,:))
            if k<I
                oflist{i}.tgk(j,k) = max(oflist{i}.tgk(j,:));
            end
        end
        for l=1:length(oflist{i}.trk(j,:))
            if l<I2
                oflist{i}.trk(j,l) = max(oflist{i}.trk(j,:));
            end
        end
    end
end

clear i j k I M I2 l M2

%% Animate a profile

% Displays and creates a movie of the profile.  Saves in the current
% Matlab folder as "temp.avi" and gets overwritten every time this section
% is run.

% INPUT: Set which profile is animated and pick the correct position and 
% time axes.
index = 14;
red = oflist{index}.trk;
green = oflist{index}.tgk;

% Make the video writer object that will assemble the movie.
Mov = VideoWriter('temp.avi');

% Set the frame rate (frames per second).
Mov.FrameRate = 4;

% Open the video writer before beginning.
open(Mov);

% Loop over all green images, display them, and add them to the movie.
% i=1:size(kymo2,1)
for i=1:size(red,1)
    % Give the profile a handle so I can delete it later.
    h1 = plot(oflist{index}.tgp, green(i,:),'g-');
    hold all
    h3 = plot(oflist{index}.trp,red(i,:),'r-');
    % Make the axes and labels pretty.
    %axis([1 pos(end) -0.01 ceil(max(max(kymo2)))]);
    axis([1 900 -0.01 1.8]);
    xlabel('Position (um)');
    ylabel('Intensity (cont. normed. to inlet)');
    % Show current time and frame number as annotation.
    h2 = annotation('textbox', [0.7,0.8,0.1,0.1],'String', ...
        {['Frame ' num2str(i)], ['Time (hr) ' num2str(oflist{index}.time(i)/60)]});
    % Make the figure into a movie frame.
    F = getframe;
    % Add the frame to the movie.
    writeVideo(Mov,F);
    % Get rid of trace and annotation without closing figure.
    delete(h1);
    delete(h2);
    delete(h3);
end

%Close the final figure.
close all

%Close the video writer.
close(Mov);

%Tidy the workspace.
clear Mov i F h1 h2 h3 green red

%%
halfMaxG = zeros(13,1440);

for i=1:length(of)
    for j=1:length(oflist{i}.time)
        %amp = ag(i,j);
        amp = max(oflist{i}.tgk(j,:));
        clear hmList
        hmList = find(abs(oflist{i}.tgk(j,:)-(amp/2)) < 0.1);
        if numel(hmList) >= 1;
            halfMaxG(i,j) = hmList(ceil(length(hmList)/2));
        else
            halfMaxG(i,j) = NaN;
        end
    end
    display([num2str(i) ' ' num2str(j) ' ' num2str(length(hmList))])
end
clear i j hmList

%%
halfMaxR = zeros(13,1440);

for i=1:length(of)
    for j=1:length(oflist{i}.time)
        %amp = ar(i,j);
        amp = max(oflist{i}.trk(j,:));
        clear hmList
        hmList = find(abs(oflist{i}.trk(j,:)-(amp/2)) < 0.1);
        if numel(hmList) >= 1;
            halfMaxR(i,j) = hmList(ceil(length(hmList)/2));
        else
            halfMaxR(i,j) = NaN;
        end
    end
    display([num2str(i) ' ' num2str(j) ' ' num2str(length(hmList))])
end

clear i j hmList