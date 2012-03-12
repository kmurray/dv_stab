function globalMotionVectors = calcGlobalMotionVectors(motionVectors, movInfo, nSubImages)

    for k = movInfo.frameRange
        if k == movInfo.frameRange(1)
            continue
        end
%         sprintf('motionvectors x')
%         [motionVectors(k,:).x]
%         sprintf('motionvectors x median')
%         median([motionVectors(k,:).x])
%             sprintf('motionvectors y')
%         [motionVectors(k,:).y]
%         sprintf('motionvectors y median')
%         median([motionVectors(k,:).y])
        globalMotionVectors(k).x = round(median([motionVectors(k,:).x]));
        globalMotionVectors(k).y = round(median([motionVectors(k,:).y]));

    end
   
    return
end

