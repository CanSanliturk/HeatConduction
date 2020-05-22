function restraintList = RestraintFactory(eBCList, hx, hy)
    
    if length(eBCList) >= 1                
        counter = 1;
        for i = 1 : length(eBCList)
             eBC = eBCList{i};
             xCoordStart = eBC.FirstPointCoord(1);
             yCoordStart = eBC.FirstPointCoord(2);
             xCoordEnd = eBC.SecondPointCoord(1);
             yCoordEnd = eBC.SecondPointCoord(2);
             specT = eBC.Temp;
             
             if (yCoordStart == yCoordEnd) % BC on horizontal portion
                 for i1 = xCoordStart : hx :xCoordEnd
                    restraintList{counter, 1} = [i1, yCoordStart, specT];
                    counter = counter + 1;
                 end
             elseif (xCoordStart == xCoordEnd)% BC on vertical portion
                 for i1 = yCoordStart : hy : yCoordEnd
                     restraintList{counter, 1} = [yCoordStart, i1, specT];
                     counter = counter + 1;
                 end
             end
        end
    end

end