function [movStabilized, movStabilizedInfo] = compensateVideo(mov, movInfo, compensationVectors)

    %New compensated frame size
    newFrameSizeFactor = 1.25;
    movStabilizedInfo.Height = ceil(newFrameSizeFactor*movInfo.Height);
    %+1 enables embedding the original movie side by side
    movStabilizedInfo.Width = ceil(newFrameSizeFactor*movInfo.Width+movInfo.Width);
    movStabilizedInfo.frameRange = movInfo.frameRange;
    
    
    %Calculate default top left corner location
    yTopOrigin = (1/2)*(movStabilizedInfo.Height-movInfo.Height);
    xSpaceSize = floor((movStabilizedInfo.Width - 2*movInfo.Width)/(2*3));
    xLeftOrigin = 2*xSpaceSize + movInfo.Width;
    
    %Crop so that we don't see video edges
    xCropPerSide = max(abs([compensationVectors(:).x]))+1;
    yCropPerSide = max(abs([compensationVectors(:).y]))+1;
    fprintf('X Crop: %d, Y crop: %d\n', xCropPerSide, yCropPerSide);
    
    
    for k = movInfo.frameRange
        %Allocate a new frame -> NOTE (height, width)
        movStabilized(k).cdata = uint8(zeros(movStabilizedInfo.Height, movStabilizedInfo.Width, 3));
        
        
        
        %Determine correct data limits
        % This is not trivial....
        % FIXME: This doesn't work properly for all edge cases!
        if (k == movInfo.frameRange(1))
            %First frame is special, no offest
            yTopCompensated = yTopOrigin;
            xLeftCompensated = xLeftOrigin;
        else
            yTopCompensated = yTopOrigin + compensationVectors(k).y;
            xLeftCompensated = xLeftOrigin + compensationVectors(k).x;
        end
        
        %Original unstabilized video edge offset
        origEdgeOffset = 10;
        
        yBottomCompensated = yTopCompensated + movInfo.Height -1;
        xRightCompensated = xLeftCompensated + movInfo.Width -1;
        
        %RGB fields
        for i = 1:3
            %The compensated video
            movStabilized(k).cdata(yTopCompensated:yBottomCompensated,      xLeftCompensated:xRightCompensated, i) = mov(k).cdata(:,:,i);
            %The original video side by side
            movStabilized(k).cdata(yTopOrigin:yTopOrigin+movInfo.Height -1, 1:movInfo.Width,                    i) = mov(k).cdata(:,:,i);
            
            %Overwrite video data to act as crop
            if (1)
               colourValue = [30 30 30];
               %STABILIZED
               %Top
               movStabilized(k).cdata(yTopOrigin - yCropPerSide:yTopOrigin + yCropPerSide, xLeftOrigin - xCropPerSide:xLeftOrigin+movInfo.Width+xCropPerSide , i) = colourValue(i);
               %Bottom
               movStabilized(k).cdata(yTopOrigin + movInfo.Height - yCropPerSide:yTopOrigin + movInfo.Height + yCropPerSide, xLeftOrigin - xCropPerSide:xLeftOrigin+movInfo.Width+xCropPerSide , i) = colourValue(i);
               %Left
               movStabilized(k).cdata(yTopOrigin - yCropPerSide:yTopOrigin + movInfo.Height + yCropPerSide, xLeftOrigin - xCropPerSide:xLeftOrigin+xCropPerSide , i) = colourValue(i);
               %Right
               movStabilized(k).cdata(yTopOrigin - yCropPerSide:yTopOrigin + movInfo.Height + yCropPerSide, xLeftOrigin + movInfo.Width - xCropPerSide:xLeftOrigin + movInfo.Width +xCropPerSide , i) = colourValue(i);
               
               %UNSTABILIZED
               %Top
               movStabilized(k).cdata(yTopOrigin - yCropPerSide:yTopOrigin + yCropPerSide, 1:movInfo.Width+xCropPerSide , i) = colourValue(i);
               %Bottom
               movStabilized(k).cdata(yTopOrigin + movInfo.Height - yCropPerSide:yTopOrigin + movInfo.Height + yCropPerSide, 1:movInfo.Width+xCropPerSide , i) = colourValue(i);
               %Left
               movStabilized(k).cdata(yTopOrigin - yCropPerSide:yTopOrigin + movInfo.Height + yCropPerSide, 1:xCropPerSide , i) = colourValue(i);
               %Right
               movStabilized(k).cdata(yTopOrigin - yCropPerSide:yTopOrigin + movInfo.Height + yCropPerSide, movInfo.Width - xCropPerSide:movInfo.Width +xCropPerSide , i) = colourValue(i);
               
            end
            
            %Outline Box
            if(1)
               %Stabilized
               movStabilized(k).cdata(yTopOrigin,                           xLeftOrigin:xLeftOrigin+movInfo.Width, i) = 255; 
               movStabilized(k).cdata(yTopOrigin+movInfo.Height,            xLeftOrigin:xLeftOrigin+movInfo.Width, i) = 255; 
               movStabilized(k).cdata(yTopOrigin:yTopOrigin+movInfo.Height, xLeftOrigin,                           i) = 255; 
               movStabilized(k).cdata(yTopOrigin:yTopOrigin+movInfo.Height, xLeftOrigin+movInfo.Width,             i) = 255; 
               
               %UnStabilized
               movStabilized(k).cdata(yTopOrigin,                           1:movInfo.Width, i) = 255; 
               movStabilized(k).cdata(yTopOrigin+movInfo.Height,            1:movInfo.Width, i) = 255; 
               movStabilized(k).cdata(yTopOrigin:yTopOrigin+movInfo.Height, 1,               i) = 255; 
               movStabilized(k).cdata(yTopOrigin:yTopOrigin+movInfo.Height, movInfo.Width,   i) = 255; 
               
            end
            
            %Mark 1st Frame
            if (k == movInfo.frameRange(1))
                movStabilized(k).cdata(1:30, 1:30, i) = 255;
            end
        end
        
        movStabilized(k).colormap = [];
        
    end
    

    return
end
