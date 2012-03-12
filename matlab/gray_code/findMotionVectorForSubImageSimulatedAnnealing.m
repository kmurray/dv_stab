function [motionVector] = findMotionVectorForSubImageSimulatedAnnealing(subImage, searchArea)
    %motionVector.x = 5;
    %motionVector.y = -6;
    

    
    %Calculated Parameters
    xRangeAbs = searchArea.Width - subImage.Width;
    yRangeAbs = searchArea.Height - subImage.Height;
    xRangeRel = round(xRangeAbs/2);
    yRangeRel = round(yRangeAbs/2);
    
    %Configurable parameters
    maxTries = 2;
    tMax = 0.7;
    tMin = 0.01;
    tDecayRate = 0.09;
    neighborhood.x = 5;
    neighborhood.y = 5;
    
%     maxTries = 3;
%     tMax = 1;
%     tMin = 0.01;
%     tDecayRate = 0.2;
%     neighborhood.x = 10;
%     neighborhood.y = 10;
    
    bestSoln.x = NaN;
    bestSoln.y = NaN;
    bestSoln.correlationValue = NaN;
    
    %iteration counter
    iters = 0;
    
    %Outer loop
    for tries = 1:maxTries
        
        %Initial Random Solution
        currentSoln.x = randi([-xRangeRel xRangeRel],1,1);
        currentSoln.y = randi([-yRangeRel yRangeRel],1,1);
        
        currentSoln.correlationValue = evalSolution(currentSoln, searchArea, subImage, xRangeRel, yRangeRel);
           
        %Accept first soln
        if isnan(bestSoln.correlationValue) || currentSoln.correlationValue < bestSoln.correlationValue
           bestSoln = currentSoln; 
        end
        
        
        %Init cooling counter
        j = 0;
        t = tMax;
        
        %Cool unitil tMin
        while (t > tMin)
            iters = iters + 1;
            
            %Cool
            t = tMax*exp(-j*tDecayRate);
            
            %Get a neighboring solution
            neighborSoln = getNeighbor(currentSoln, neighborhood, xRangeRel, yRangeRel);
            
            %Evaluate it
            neighborSoln.correlationValue = evalSolution(neighborSoln, searchArea, subImage, xRangeRel, yRangeRel);
            
            %Always keep the best solution
            % This is an optimization to the prototypical SA algorithm
            if neighborSoln.correlationValue < bestSoln.correlationValue
                bestSoln = neighborSoln;
                %fprintf('\tSA: \t Try: %d, Cooling Loop %d, new best soln: (%d,%d) correlation: %d\n', tries, j, bestSoln.x, bestSoln.y, bestSoln.correlationValue);
            end
            
            %Accept probabalistically based on correlationValue delta, and
            %temperature.  It is this probabilistic nature that prevents us
            %from becoming stuck in local optima
            if (probabilisticAccept(currentSoln.correlationValue, neighborSoln.correlationValue, t))
                %Neighbor is the new solution
                currentSoln = neighborSoln;
            end
            
            %Cooling increment
            j = j + 1;
        end
    end
    
    %Final solution
    motionVector = bestSoln;
    motionVector.iters = iters;
    
    %fprintf('\tSA: \t Final Solution: (%d, %d), correlation: %d, iters: %d\n', motionVector.x, motionVector.y, motionVector.correlationValue, iters)
    
    return

end

function accept = probabilisticAccept(currentCorrelation, neighboorCorrelation, t)
    
    accept = 0;
    
    %Minimization, so want smallest correlation value
    if (neighboorCorrelation < currentCorrelation)
        accept = 1;
    else
        %Semi-random acceptance rate, a significantly better solution is
        %much more likely to be accepted than one that is worse.  As the 
        %temparture decreases this emphasis is increased
        
        %Random double between zero and one
        randValue = rand(1,1);
        %Exponential acceptance value, based on temp and correlation
        %difference
        acceptanceValue = exp( (currentCorrelation - neighboorCorrelation)/t );
        
        %Evaluate
        accept = (randValue < acceptanceValue );
    end
    
    return
end

function neighbor = getNeighbor(currentSoln, neighborhood, xRangeRel, yRangeRel)
    
    %TODO:

    
    %Specified search region comes as the neighborhood object
    randxUpperLimit = neighborhood.x;
    randxLowerLimit = -neighborhood.x;
    randyUpperLimit = neighborhood.y;
    randyLowerLimit = -neighborhood.y;
    
    % Use this unless it would result in going out of valid range
    if currentSoln.x + neighborhood.x > xRangeRel
       randxUpperLimit = xRangeRel - currentSoln.x;
    end
    
    if currentSoln.x - neighborhood.x < -xRangeRel
        randxLowerLimit = -xRangeRel - currentSoln.x;
    end
    
    if currentSoln.y + neighborhood.y > yRangeRel
       randyUpperLimit = yRangeRel - currentSoln.y;
    end
    
    if currentSoln.y - neighborhood.y < -yRangeRel
        randyLowerLimit = -yRangeRel - currentSoln.y;
    end
        
    
    %Get the random neighbor
    neighbor.x = currentSoln.x + randi([randxLowerLimit randxUpperLimit], 1,1);
    neighbor.y = currentSoln.y + randi([randyLowerLimit randyUpperLimit], 1,1);
    
    
    
    return
end

function correlationValue = evalSolution(currentSoln, searchArea, subImage, xRangeRel, yRangeRel)
    %Intermediate x related values
    xSearchAreaLeft = xRangeRel + currentSoln.x +1;
    xSearchAreaRight = xRangeRel + currentSoln.x + subImage.Width;
    assert(xSearchAreaRight <= searchArea.Width);
    
    %Intermediate y related values
    ySearchAreaTop = yRangeRel + currentSoln.y +1;
	ySearchAreaBot = yRangeRel + currentSoln.y + subImage.Height;
    assert(ySearchAreaBot <= searchArea.Height);

    %The search area
    searchAreaCorrelationRegion = searchArea.cdata(ySearchAreaTop:ySearchAreaBot, xSearchAreaLeft:xSearchAreaRight);
    
    %The bitxored image
    correlationImage = bitxor(subImage.cdata(:,:),  searchAreaCorrelationRegion);
    
    %The correlated value
    correlationValue = sum(correlationImage(:));
    
    return
end