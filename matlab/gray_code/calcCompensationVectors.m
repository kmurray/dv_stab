function compensationVectors = calcCompensationVectors(globalMotionVectors, movInfo)
    
    %TUNABLE FACTORS
    % decayFactor - controls how much influence the previous compensation 
    %  vector has on the current motion vector.  0 < decayFactor < 1
    % preAmpFactor - How much amplification to apply on the incomming
    %   motion vector
    %decayFactor = 0.99;
    preAmpFactor = 1.0;
    
    %Integration time
    nOldVectors = 20;
    %Evenly spaced values between 1 and zero, ' stores a column vector
    linScaleFactor = [1:-1/(nOldVectors-1):0]';
    %Evenly spaced values from the exponential function
    expScaleFactor = exp(-1*(nOldVectors-1):0);
    
    %The actual scaling factor
    decayFactor = linScaleFactor;
    %decayFactor = expScaleFactor
    
    %Row vector of old values, init to zero
    % first elem is most recent
    oldValuesX = zeros(1, nOldVectors);
    oldValuesY = zeros(1, nOldVectors);
    
    
    for k = movInfo.frameRange
        if (k == movInfo.frameRange(1))
            %The first frame is special, it recieves no compensation
            compensationVectors(k).x = 0;
            compensationVectors(k).y = 0;
        else
	    %Row and column vector mulitplication produces a scalar value
            oldEffectiveX = oldValuesX*linScaleFactor;
            oldEffectiveY = oldValuesY*linScaleFactor;
            
            compensationVectors(k).x = round(oldEffectiveX + preAmpFactor*globalMotionVectors(k).x);
            compensationVectors(k).y = round(oldEffectiveY + preAmpFactor*globalMotionVectors(k).y);
            %oldX = globalMotionVectors(k).x;
            %oldY = globalMotionVectors(k).y;
            
            %Update the stored values of old motion vectors
            % This is key for smoothing vibrations with long periods
            
            %This process updates the values in the oldValues arrays
            % e.g: 
            %       >> oldValuesX = [55 0 0 0 1]
            %
            %       oldValuesX =
            %
            %          55     0     0     0     1
            %           
            %       >> oldValuesX = circshift(oldValuesX, [0, 1])
            %           
            %       oldValuesX =
            %
            %           1    55     0     0     0
            %       
            %       Next we store add a new motion vector to the list
            %       overwritting the oldest value (1) as a result of the shift
            %       
            %       >> oldValuesX(1) = 22
            %       
            %       oldValuesX = 
            %       
            %           22    55     0     0     0
            
            %Shift the values
            oldValuesX = circshift(oldValuesX, [0 1]);
            oldValuesY = circshift(oldValuesY, [0 1]);
            
            %Update the first position
            oldValuesX(1) = globalMotionVectors(k).x;
            oldValuesY(1) = globalMotionVectors(k).y;
            
        end
        
        fprintf('Frame: %d compensation vectors: (%d, %d)\n', k, compensationVectors(k).x, compensationVectors(k).y)
        
        
        
    end
    
    return
end
