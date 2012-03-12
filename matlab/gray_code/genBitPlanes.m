function [movGcbp] = genBitPlanes(movGray, movInfo, bit_plane_num)
        
    for k = movInfo.frameRange
        movGcbp(k).cdata = bitget(movGray(k).cdata,bit_plane_num);
        movGcbp(k).colormap = [];
    end
    return
end