function [subImages, searchAreas] = getSubImages(frame, subImagesInfo, movInfo)
    searchAreaWidth = round((1/subImagesInfo.nX)*movInfo.Width);
    searchAreaHeight = round((1/subImagesInfo.nY)*movInfo.Height);
    %sprintf('search area width height %d, %d\n', searchAreaWidth, searchAreaHeight)
    %Sub Image Hardcoded 80% of the search area
    subImagePercent = 0.8;
    subImageWidth = round(subImagePercent*searchAreaWidth);
    subImageHeight = round(subImagePercent*searchAreaHeight);
    subImageXOffset = round( (searchAreaWidth - subImageWidth)/2 );
    subImageYOffset = round( (searchAreaHeight - subImageHeight)/2 );
    
    
    %Var declarations
    searchAreas = [];   
    subImages.cdata = [];
    
    %Count which sub image we are on
    subImageCnt = 1;
      
    %Image stored as (y,x) = (1,1) is the top left of the frame
    % (Matlab arrays start at 1)
    for xCnt = 0:subImagesInfo.nX-1
        %Sanity Check
        assert(subImageCnt <= subImagesInfo.nSubImages + 1, 'Too many sub images');
        
        %Calculate useful location values
        xSearchAreaLeft = xCnt*searchAreaWidth + 1;
        assert(xSearchAreaLeft >= 1);
        
        xSearchAreaRight = xSearchAreaLeft + searchAreaWidth -1;
        assert (xSearchAreaRight <= movInfo.Width);
        
        xSubImageLeft = xSearchAreaLeft + subImageXOffset + 1;
        assert(xSubImageLeft >= 1);
        
        xSubImageRight = xSubImageLeft + subImageWidth -1;
        assert(xSubImageRight <= movInfo.Width);

        
        for yCnt = 0:subImagesInfo.nY-1
            %Calculate usefule location values
            ySearchAreaTop = yCnt*searchAreaHeight + 1;
            
            assert(ySearchAreaTop >= 1);

            ySearchAreaBot = ySearchAreaTop + searchAreaHeight -1;
            assert (ySearchAreaBot <= movInfo.Height, 'Bottom edge (%d) out of range %d', ySearchAreaBot, movInfo.Height + 1);

            ySubImageTop = ySearchAreaTop + subImageYOffset + 1;
            assert(ySubImageTop >= 1);

            ySubImageBot = ySubImageTop + subImageHeight -1;
            assert(ySubImageBot <= movInfo.Height);

            %sprintf('SearchArea (%d, %d) x (%d, %d)\n', xSearchAreaLeft, ySearchAreaTop, ySearchAreaBot, xSearchAreaRight )
            
            %Grab search area data
            searchAreas(subImageCnt).cdata = frame(ySearchAreaTop:ySearchAreaBot, xSearchAreaLeft:xSearchAreaRight);
            searchAreas(subImageCnt).Width = searchAreaWidth;
            searchAreas(subImageCnt).Height = searchAreaHeight;

            %sprintf('SubImage (%d, %d) x (%d, %d)\n', xSubImageLeft, ySubImageTop, xSubImageRight, ySubImageBot )
            %Grab sub image data                                      
            subImages(subImageCnt).cdata = frame(ySubImageTop:ySubImageBot, xSubImageLeft:xSubImageRight);
            subImages(subImageCnt).Width = subImageWidth;
            subImages(subImageCnt).Height = subImageHeight;
            
            %Increment to next sub image
            subImageCnt = subImageCnt + 1;
        end
    end
    
    
    return
end