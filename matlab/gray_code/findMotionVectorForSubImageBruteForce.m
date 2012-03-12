function [motionVector] = findMotionVectorForSubImageBruteForce(subImage, searchArea)

        xRangeAbs = searchArea.Width - subImage.Width;
        yRangeAbs = searchArea.Height - subImage.Height;
        xRangeRel = round(xRangeAbs/2);
        yRangeRel = round(yRangeAbs/2);
        
        %Default values to hopefully catch any errors
        motionVector.x = 'NaN';
        motionVector.y = 'NaN';
        motionVector.correlationValue = 'NaN';
        
        %iteration count
        iters = 0;
        
        for x = -xRangeRel:xRangeRel
            xSearchAreaLeft = xRangeRel + x +1;
            xSearchAreaRight = xRangeRel + x + subImage.Width;
            assert(xSearchAreaRight <= searchArea.Width);
            
            for y = -yRangeRel:yRangeRel
                iters = iters + 1;
                
                ySearchAreaTop = yRangeRel + y +1;
                ySearchAreaBot = yRangeRel + y + subImage.Height;
                assert(ySearchAreaBot <= searchArea.Height);
                
                %Calculate the correlation value
                % This is just the bitwise xor of each pixel
                %  FAST in hardware!
                %sprintf('Search Area: (%d,%d) x (%d, %d)\n', x, y, xSearchAreaRight, ySearchAreaBot)
                %sprintf('SubImage: (%d, %d)\n', size(subImage.cdata))
                searchAreaCorrelationRegion = searchArea.cdata(ySearchAreaTop:ySearchAreaBot, xSearchAreaLeft:xSearchAreaRight);
                correlationImage = bitxor(subImage.cdata(:,:),  searchAreaCorrelationRegion);
                correlationValue = sum(correlationImage(:));
                
%                 figure,imshow(subImage.cdata, [0 1])
%                 figure,imshow(searchCorrelateRegion, [0 1]);
%                 figure,imshow(correlationValue, [0 1]);
%                 assert(0);
                
                %Initial case
                if (motionVector.correlationValue == 'NaN')
                    motionVector.correlationValue = correlationValue;
                    motionVector.x = x;
                    motionVector.y = y;
                end
                
                %Best correlation value is the motion vector
                if (correlationValue < motionVector.correlationValue)
                    motionVector.correlationValue = correlationValue;
                    motionVector.x = x;
                    motionVector.y = y;
                end
            end
        end
    
    motionVector.iters = iters;
    %fprintf('\tBF: \t Final Solution: (%d, %d), correlation: %d, iters: %d\n', motionVector.x, motionVector.y, motionVector.correlationValue, iters)

    return
end