%% This script is for preparing the outlet-filled gels for fitting to an 
% exponential decay curve.  It fits only the decay from the peak.  Start
% with a profile vector, time vector, and position vector.


%% Chop off most of the inlet.

% Inlet weirdness can make it difficult to find the peak in each frame.
% Chop off enough inlet that the peak is the always the global maximum.

% User input: posCutOff (in microns). Smaller values will be discarded.
posCutOff = 200;

% Find the index in the position vector corresponding to this cut-off.
indexCutOff = find(pos<posCutOff, 1, 'last' );

% Make a new profile vector.
for i=1:frames
    inletRemoved(i,:) = kymo_green(i,(indexCutOff:end))/inlet(1,i);
end

clear posCutOff indexCutOff i

%% Use only the decaying section of the curve

% Preallocate an array of zeros of the correct size.
decayOnly = zeros(frames, size(inletRemoved,2));

% Loop through all time steps and find the peak (global maximum).  All
% values to the left of the peak are set to zero.
for i=1:320
    for j=1:size(inletRemoved,2);
        [~,maxInd] = max(inletRemoved(i,:));
        if j>=maxInd
            decayOnly(i,j) = inletRemoved(i,j);
        end
    end
end

clear i j maxInd

%% Zero the position of the first peak and make a new position vector.

[~,firstPeak] = max(decayOnly(1,:));

for i=1:size(time,2)
    cleanProfile(i,:) = decayOnly(i,(firstPeak:end));
end

cleanPos = pos((end+1-size(cleanProfile,2)):end) ...
    - pos((end+1-size(cleanProfile,2)));

clear i firstPeak

%% Check the prepared profile by making an animation.

% Make the video writer object that will assemble the movie.
close all
grnMov = VideoWriter('temp.avi');

% Set the frame rate.
grnMov.FrameRate = 4;

% Open the video writer before beginning.
open(grnMov);

% Loop over all green images, display them, and add them to the movie.
for i=1:frames
    h1 = plot(cleanPos,cleanProfile(i,:),'g-');
    hold all;
    axis([1 cleanPos(end) -0.01 1.5]);
    xlabel('Position (um)');
    ylabel('Intensity');
    title('Profile prepared for fit');
    h3 = annotation('textbox', [0.6,0.7,0.1,0.1],'String', ...
        {['Frame ' num2str(i)], ['Time (min) ' num2str(time(i),3)]});
    F = getframe;
    % Add the frame to the movie.
    writeVideo(grnMov,F);
    delete(h1);
    delete(h3);
end

%Close the final figure.
close all

%Close the video writer.
close(grnMov);

%Tidy the workspace.
clear i F h1 h3 grnMov

%% Pre-allocate vectors to hold the fit parameters and RMSE.

aVec = zeros(1, frames);
bVec = zeros(1, frames);
cVec = zeros(1,frames);
rmse = zeros(1,frames);

%% Fit all frames of the experiment to the equation y = exp(-(x-a)/b)+c

% Make an initial guess at the parameters.
% The vector has the form [a b c].
guess = [70 100 0.1];

% Clear parameter names in preparation for fitting.
clear a b c; 

% Loop over all frames of the experiment and fit the curves.
for i=1:frames
    
    % Find index of maximum value (peak).  Fitting routine excludes any
    % points to the left of the peak.
    [~, maxIndex] = max(cleanProfile(i,:));
    
    % Display current time step to monitor progress.
    display(i);
    
    % Perform the fit.
    [fitresult, gof] = FitExpDecay(cleanPos, cleanProfile(i,:), ...
        maxIndex, guess);
    
    % Assign the resulting parameters to vectors.
    aVec(i) = fitresult.a;
    bVec(i) = fitresult.b;
    cVec(i) = fitresult.c;
    rmse(i) = gof.rmse;
       
end

%Tidy the workspace
clear i guess maxIndex gof fitresult

%% Animate the profile along with the fit

% Make the video writer object that will assemble the movie.
grnMov = VideoWriter('temp.avi');

% Set the frame rate.
grnMov.FrameRate = 4;

% Open the video writer before beginning.
open(grnMov);

% Loop over all green images, display them, and add them to the movie.
% Also display the fit for each time step.
for i=1:frames
    h1 = plot(test4(i,:),'g-');
    hold all;
    % This is the fit equation: y = a*exp(-b*x)+c
    y = exp(-(pos1-aVec(i))/bVec(i))+cVec(i);
    h2 = plot(y,'k-');
    axis([1 size(test4,2) -0.01 1.5]);
    xlabel('Position (um)');
    ylabel('Intensity');
    title('Profile and fit overlaid');
    h3 = annotation('textbox', [0.6,0.7,0.1,0.1],'String', ...
        {['Frame ' num2str(i)], ['Time (min) ' num2str(time(i),3)]});
    F = getframe;
    % Add the frame to the movie.
    writeVideo(grnMov,F);
    delete(h1);
    delete(h2);
    delete(h3);
end

%Close the final figure.
close all

%Close the video writer.
close(grnMov);

%Tidy the workspace.
clear i F h1 h2 h3 grnMov

%% Show fit results
close all
figure('units','normalized','position',[.2 .1 .6 .7])

subplot(2,2,1);
plot(time,rmse,'k','LineWidth',3);
title('Exp. fit: RMSE vs time');
xlabel('Time (minutes)');
ylabel('RMSE');
hold all

subplot(2,2,2);
plot(time,aVec,'g','LineWidth',3);
title('Exp. fit: x-Offset vs time');
xlabel('Time (minutes)');
ylabel('x-Offset (um)');
hold all

subplot(2,2,3);
plot(time,bVec,'b','LineWidth',3);
title('Exp. fit: Slope vs time');
xlabel('Time (minutes)');
ylabel('Slope (um)');

subplot(2,2,4);
plot(time,cVec,'r','LineWidth',3);
title('Exp. fit: y-Offset vs time');
xlabel('Time (minutes)');
ylabel('y-Offset');

%% Tidy workspace before saving
clear inletRemoved decayOnly y
