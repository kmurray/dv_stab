function [movGray] = genGrayScale(mov, movInfo)
    %Mov is RGB 'true color' format:
    %   Each frame is stored as a 'width x height x 3' matrix
    %   Where each of the '3' frames represents the red, green and blue
    %   components
    for k = movInfo.frameRange
        %RGB to NTSC format
        ntscFrame = rgb2ntsc(mov(k).cdata);
        
        %NTSC also stores each frame in a 'width x height x 3'
        % BUT: the components are now 'Y, I, Q' corresponding to
        % Luminance (Y) and chrominance/color (I, Q) components
        % By extracting only the luminance (Y) data we get a 
        % gray scale indexed image      
        grayFrameDouble = ntscFrame(:,:,1);
        
        % Store as uint8 rather than double
        movGray(k).cdata = uint8(round(grayFrameDouble*255));
    end
    
    return
end