function [mov, movInfo] = loadVideo(fileName, frameRange)
    shakyVideoObj = VideoReader(fileName);

    movInfo.nFrames = length(frameRange);
    movInfo.frameRange = frameRange;
    movInfo.Height = shakyVideoObj.Height;
    movInfo.Width = shakyVideoObj.Width;
    movInfo.FramesPerSecond = shakyVideoObj.FrameRate;
    % Read one frame at a time.
    for k = frameRange
        mov(k).cdata = read(shakyVideoObj, k);
        mov(k).colormap = [];
    end

    return
end
