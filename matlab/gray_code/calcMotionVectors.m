function [motionVectors] = calcMotionVectors(movGcbp, movInfo, subImagesInfo)
    
    

    %Global stats
    netBFCorrelation = 0;
    netSACorrelation = 0;
    netBFx = 0;
    netSAx = 0;
    netBFy = 0;
    netSAy = 0;
    netBFiters = 0;
    netSAiters = 0;


    %Each frame
    for k = movInfo.frameRange
        
        if k == movInfo.frameRange(1)
            %Get the search areas for the first frame
            % No motion estimation is done on the first frame, but we need to set-
            % up the search areas for the second frame
            [~, lastFrameSearchAreas] = getSubImages(movGcbp(k).cdata, subImagesInfo, movInfo);
            continue;
        end
        
        %Split the frame into n sub images
        [subImages, searchAreas] = getSubImages(movGcbp(k).cdata, subImagesInfo, movInfo);
        
        frameMotionVectors = [];
        

        %Each sub image
         for i = 1:subImagesInfo.nSubImages
            fprintf('Frame #: %d, SubImage: %d\n', k, i)
            
            %Calc Motion Vector for sub image

            
            
            motionVectorSA = findMotionVectorForSubImageSimulatedAnnealing(subImages(i), lastFrameSearchAreas(i));
            
            if 0
                motionVectorBF = findMotionVectorForSubImageBruteForce(subImages(i), lastFrameSearchAreas(i));
                
                %Some SA vs BF stats
                correlationDiff = motionVectorBF.correlationValue - motionVectorSA.correlationValue;
                correlationDiffPct = prcdiff(motionVectorBF.correlationValue, motionVectorSA.correlationValue);
                xDiff = motionVectorBF.x - motionVectorSA.x;
                xDiffPct = prcdiff(motionVectorBF.x, motionVectorSA.x);
                yDiff = motionVectorBF.y - motionVectorSA.y;
                yDiffPct = prcdiff(motionVectorBF.y, motionVectorSA.y);
                itersDiff = motionVectorBF.iters - motionVectorSA.iters;
                itersDiffPct = prcdiff(motionVectorBF.iters, motionVectorSA.iters);

                %Sub image stats
                fprintf('\tSTAT: correlationDiff: %d (%.2f%%), xDiff: %d (%.2f%%), yDiff: %d (%.2f%%), itersDiff: %d (%.2f%%)\n', correlationDiff, correlationDiffPct, xDiff, xDiffPct, yDiff, yDiffPct, itersDiff, itersDiffPct)

                %global stats
                netBFCorrelation = netBFCorrelation + motionVectorBF.correlationValue;
                netSACorrelation = netSACorrelation + motionVectorSA.correlationValue;
                netBFx = netBFx + motionVectorBF.x;
                netSAx = netSAx + motionVectorSA.x;
                netBFy = netBFy + motionVectorBF.y;
                netSAy = netSAy + motionVectorSA.y;
                netBFiters = netBFiters + motionVectorBF.iters;
                netSAiters = netSAiters + motionVectorSA.iters;
            end
            
            motionVector = motionVectorSA;
            
            %Store Motion Vectors for Frame and sub image
            
            
            motionVectors(k,i) = motionVector;
            %fprintf('motionvector (%d, %d)\n', motionVector.x, motionVector.y);
        end
        
        
        
        %Save search areas for next frame
        lastFrameSearchAreas = searchAreas;
    end

    if 0
        %Video totals
        netCorrelDiff = prcdiff(netBFCorrelation, netSACorrelation);
        netXDiff = prcdiff(netBFx, netSAx);
        netYDiff = prcdiff(netBFy, netSAy);
        netItersDiff = prcdiff(netBFiters, netSAiters);
        fprintf('\nSTAT-TOTAL: correlationDiff: %.2f%%, xDiff: %.2f%%, yDiff: %.2f%%, itersDiff: %.2fx (%.2f%%)\n', netCorrelDiff, netXDiff, netYDiff, netBFiters/netSAiters, netItersDiff)
    end
    
    return

end



function prc = prcdiff(a, b)
%PRCDIFF Percent difference.
%
%   PRCDIFF(A, B) computes the percent difference between A and B.  That is,
%   the difference in percent between A and B relative to A.
%
%   Author:      Peter John Acklam
%   Time-stamp:  2003-10-13 14:28:03 +0200
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   % check number of input arguments
   error(nargchk(2, 2, nargin));

   i = ~a;          % true when a is zero
   j = ~b;          % true when b is zero

   % use an adjusted denominator to avoid "division by zero" error
   c = a;
   c(i) = 1;

   prc = 100 * (b - a) ./ c;

   prc(i &  j) = NaN;                           % when a = 0 and b = 0
   prc(i & ~j) = sign(b(i & ~j)) * Inf;         % when a = 0 and b ~= 0
   return
end