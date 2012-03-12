function [] = stabilizeVideo(fileName, frameRange, nXSubImages, nYSubImages)
    
%     fprintf('DEBUG: Resetting random number seed for debugging!\n')
%     defaultStream = RandStream.getDefaultStream();
%     reset(defaultStream);
%     
    [mov, movInfo] = loadVideo(fileName, frameRange);
    
    subImagesInfo.nX = nXSubImages;
    subImagesInfo.nY = nYSubImages;
    subImagesInfo.nSubImages = nXSubImages*nYSubImages;
    
    % setup figure
    if (0)
        H1 = figure; 
        set(H1,'name','Original Movie');
        scrz  =  get(0,'ScreenSize');
        set(H1,'position',...     % [left bottom width height]
             [60 scrz(4)-100-(movInfo.Height+50) ...
                 movInfo.Width+50 movInfo.Height+50]);
        % play orig movie
        movie(H1,mov,1,movInfo.FramesPerSecond,[25 25  0  0])
        close(H1)
    end
    
    %Convert rgb/truecolor to NTSC chroma channel
    movGray = genGrayScale(mov, movInfo);
    %figure;imshow(movGray(movInfo.nFrames).cdata); % show last frame

    %Extract the specific bit plane
    bitPlaneNumber = 5;
    movGcbp = genBitPlanes(movGray, movInfo, bitPlaneNumber);
    %figure;imshow(movGcbp(movInfo.nFrames).cdata, [0 1]); % show last frame using BW colormap
    
    %Calculate the motion vectors
    fprintf('Calculating Motion Vectors\n');
    tic;
    localMotionVectors = calcMotionVectors(movGcbp, movInfo, subImagesInfo);
    t = toc; 
    fprintf('Motion Vectors calculated at %.2f fps\n',(movInfo.nFrames-1)/t);
    
%     sprintf('Showing MotionVectors\n');
%     for k = 2:movInfo.nFrames
%         sprintf('Frame # %d:\n', k)
%         for j = 1:nSubImages
%             sprintf('\t SubImage %d: (%d,%d)\n', j, localMotionVectors(k,j).x, localMotionVectors(k,j).y)
%         end
%     end
    
    %Calculate global motion vectors
    globalMotionVectors = calcGlobalMotionVectors(localMotionVectors, movInfo, subImagesInfo.nSubImages)
    
    
    
    %Calculate compensation vectors
    compensationVectors = calcCompensationVectors(globalMotionVectors, movInfo);
    
    
    
    %Actually Stabilize the video
    [movStabilized, movStabilizedInfo] = compensateVideo(mov, movInfo, compensationVectors);
    
    %Playback the stabilized video
    if (1)

        H2 = figure; 
        set(H2,'name','Stabilized Movie');
        scrz  =  get(0,'ScreenSize');
        set(H2,'position',...     % [left bottom width height]
             [60 scrz(4)-100-(movStabilizedInfo.Height+50) ...
                 movStabilizedInfo.Width+50 movStabilizedInfo.Height+50]);
        
        playbackFrameRate = 60;
        numPlays = 2000;
        % play original movie
        movie(H2,movStabilized(movStabilizedInfo.frameRange),numPlays,playbackFrameRate,[25 25  0  0])
        close(H2)
    end
    
end