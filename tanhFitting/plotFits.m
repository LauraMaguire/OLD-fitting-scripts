for j=13:13%length(of)
for i=1:length(oflist{j}.time)
    [fitresult,gof] = tanhFit(oflist{j}.tgp,oflist{j}.tgk(i,:),i);%tanhFit(oflist{j}.pos,oflist{j}.kymo_green(i,:)/oflist{j}.inlet(1,i),i);
    ag(j,i) = fitresult.a;
    bg(j,i) = fitresult.b;
    cg(j,i) = fitresult.c;
    dg(j,i) = fitresult.d;
    [fitresult,gof] = tanhFit(oflist{j}.trp,oflist{j}.trk(i,:),i);%tanhFit(oflist{j}.pos,oflist{j}.kymo_red(i,:)/oflist{j}.inlet(2,i),i);%tanhFit(oflist{j}.trp,oflist{j}.trk(i,:),i);
    ar(j,i) = fitresult.a;
    br(j,i) = fitresult.b;
    cr(j,i) = fitresult.c;
    dr(j,i) = fitresult.d;
    display(num2str(i));
    
% % Create a figure for the plots.
%     if i==1
%         figure( 'Name', 'untitled fit 1' );
% 
%         % Plot fit with data.
%         subplot( 2, 1, 1 );
%         h = plot( fitresult, xData, yData );
%         legend( h, 'testg vs. posg', 'untitled fit 1', 'Location', 'NorthEast' );
%         % Label axes
%         xlabel posg
%         ylabel testg
%         grid on
% 
%         % Plot residuals.
%         subplot( 2, 1, 2 );
%         h = plot( fitresult, xData, yData, 'residuals' );
%         legend( h, 'residuals', 'Zero Line', 'Location', 'NorthEast' );
%         % Label axes
%         xlabel posg
%         ylabel testg
%         grid on
%     end
end
end

%% Animate a profile

% Displays and creates a movie of the profile.  Saves in the current
% Matlab folder as "temp.avi" and gets overwritten every time this section
% is run.

% INPUT: Set which profile is animated and pick the correct position and 
% time axes.
index = 8;
gx = oflist{index}.tgp;%oflist{index}.pos;
rx = oflist{index}.trp;%oflist{index}.pos;
gresult = oflist{index}.tgk;%oflist{index}.kymo_green;%oflist{index}.tgk;
rresult = oflist{index}.trk;%oflist{index}.kymo_red;

% Make the video writer object that will assemble the movie.
Mov = VideoWriter('temp.avi');

% Set the frame rate (frames per second).
Mov.FrameRate = 4;

% Open the video writer before beginning.
open(Mov);

% Loop over all green images, display them, and add them to the movie.
% i=1:size(gresult,1)
for i=1:size(gresult,1)
    gfit = ag(index,i)*tanh(-(gx-bg(index,i))/cg(index,i))+dg(index,i);
    rfit = ar(index,i)*tanh(-(rx-br(index,i))/cr(index,i))+dr(index,i);
    % Give the profile a handle so I can delete it later.
    h1 = plot(oflist{index}.tgp, gfit,'k-');
    hold all
    h3 = plot(oflist{index}.tgp,gresult(i,:),'g-');%/oflist{index}.inlet(1,i),'g-');
    h4 = plot(oflist{index}.trp, rfit,'k--');
    h5 = plot(oflist{index}.trp,rresult(i,:),'r-');%/oflist{index}.inlet(2,i),'r-');
    % Make the axes and labels pretty.
    %axis([1 pos(end) -0.01 ceil(max(max(kymo2)))]);
    axis([1 900 -0.01 3]);
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
    delete(h4);
    delete(h5);
end

%Close the final figure.
close all

%Close the video writer.
close(Mov);

%Tidy the workspace.
clear Mov i F h1 h2 h3 green red gx rx

%%
plot(oflist{index}.time,cg(index,1:length(oflist{index}.time)));
hold all
plot(oflist{index}.time,cr(index,1:length(oflist{index}.time)));

%%
plot(oflist{index}.time,bg(index,1:length(oflist{index}.time)));
hold all
plot(oflist{index}.time,br(index,1:length(oflist{index}.time)));
%%
plot(oflist{index}.time,ag(index,1:length(oflist{index}.time)));
hold all
plot(oflist{index}.time,ar(index,1:length(oflist{index}.time)));
%%
plot(oflist{index}.time,dg(index,1:length(oflist{index}.time)));
hold all
plot(oflist{index}.time,dr(index,1:length(oflist{index}.time)));

%%
figure
hold on
for i=1:length(of)
%plot(oflist{i}.time,cg(i,1:length(oflist{i}.time)),'LineWidth',2);
plot(oflist{i}.time,br(i,1:length(oflist{i}.time)));
end
hold off
%%
figure
hold on
for i=1:length(of)
    if (i==3)||(i==12)||(i==13)||(i==9)
        %plot(oflist{i}.time,bg(i,1:length(oflist{i}.time)),'g--','LineWidth',2);
        %plot(oflist{i}.time,br(i,1:length(oflist{i}.time)),'r--');
    else
        plot(oflist{i}.time,bg(i,1:length(oflist{i}.time)),'LineWidth',2);
        plot(oflist{i}.time,br(i,1:length(oflist{i}.time)));
    end
end
hold off

%%
figure
hold on
for i=1:length(of)
    if (i==3)||(i==12)||(i==13)||(i==9)
        %plot(oflist{i}.time,bg(i,1:length(oflist{i}.time)),'g--','LineWidth',2);
        %plot(oflist{i}.time,br(i,1:length(oflist{i}.time)),'r--');
        display(num2str(i));
    elseif (i==8)||(i==7)
        plot(oflist{i}.time,ag(i,1:length(oflist{i}.time)),'g--','LineWidth',2);
    else
        plot(oflist{i}.time,ag(i,1:length(oflist{i}.time)),'LineWidth',2);
        plot(oflist{i}.time,ar(i,1:length(oflist{i}.time)));
    end
end
hold off
%% 7,8,11 - 11 is weird in a lot of ways, 7 and 8 have largest amplitudes
% and are right next to each other in time, same batch of gel mix, nothing
% obviously wrong with mix or gel (no other OF gels ran with that batch)
%%
figure
hold on
title('Half max squared vs time');
xlabel('Time (min)')
ylabel('Half max squared (um^2)');
for i=1:length(of)
    if (i==3)||(i==12)||(i==13)||(i==9)
        %plot(oflist{i}.time,halfMaxG(i,1:length(oflist{i}.time)).^2,'b-','LineWidth',2);
        %plot(oflist{i}.time,halfMaxR(i,1:length(oflist{i}.time)).^2,'k-');
        display('nope!')
    elseif (i==8)||(i==11)||(i==7)
        plot(oflist{i}.time,halfMaxG(i,1:length(oflist{i}.time)).^2,'c-','LineWidth',2);
        plot(oflist{i}.time,halfMaxR(i,1:length(oflist{i}.time)).^2,'r-');
    else
        plot(oflist{i}.time,halfMaxG(i,1:length(oflist{i}.time)).^2,'g-','LineWidth',2);
        plot(oflist{i}.time,halfMaxR(i,1:length(oflist{i}.time)).^2,'r-');
    end
end
hold off
%%
figure
hold on
title('Half max vs time');
xlabel('Time (min)')
ylabel('Half max (um)');
for i=1:length(of)
    if (i==3)||(i==12)||(i==13)||(i==9)
        plot(oflist{i}.time,halfMaxG(i,1:length(oflist{i}.time)),'b-','LineWidth',2);
        plot(oflist{i}.time,halfMaxR(i,1:length(oflist{i}.time)),'k-');
        display('nope!')
    elseif (i==7)||(i==8)||(i==11)
        plot(oflist{i}.time,halfMaxG(i,1:length(oflist{i}.time)),'c-','LineWidth',2);
        plot(oflist{i}.time,halfMaxR(i,1:length(oflist{i}.time)),'r-');
    else
        plot(oflist{i}.time,halfMaxG(i,1:length(oflist{i}.time)),'g-','LineWidth',2);
        plot(oflist{i}.time,halfMaxR(i,1:length(oflist{i}.time)),'r-');
    end
end
legend(leg);
hold off
%%       
plot(oflist{index}.time,halfMaxG(index,1:length(oflist{index}.time)).^2,'g-','LineWidth',2);
hold all
plot(oflist{index}.time,halfMaxR(index,1:length(oflist{index}.time)).^2,'r-');