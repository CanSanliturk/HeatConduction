function fGlobal = ForceVectorAssembler(meshList, nodeList, nBCList, nDof, f, h, meshType)

    syms x y;
    nodeListSize = size(nodeList);
    
    nNodeY = nodeListSize(1);
    nNodeX = nodeListSize(2);
    
    meshListSize = size(meshList);
    nElmY = meshListSize(1);
    nElmX = meshListSize(2);    
    
    qGiven = zeros(nDof, 1);
    
    for i = 1 : nNodeY
        for j = 1 : nNodeX   
            node = nodeList{i, j};            
            if (isempty(node))            
                continue;
            else
                nodeCoord = [node.X, node.Y];
                dofIndex = node.DofIndex;                
            end
            try
                if (dofIndex <= nDof)
                    for k = 1 : size(nBCList)
                    
                        nbc = nBCList{i, 1};
                        firstPoint = nbc.FirstPointCoord;
                        secondPoint = nbc.SecondPointCoord;                        
                        
                        if ((firstPoint(2) - secondPoint(2)) == 0) % Horizontal nbc
                            
                            for xCoord = firstPoint(1) : h : secondPoint(1)
                                if (nodeCoord == [xCoord, firstPoint(2)])
                                   q(dofIndex, 1) = nbc.Flux;
                                   break;
                                end
                            end
                        else                            
                            for yCoord = firstPoint(2) : h : secondPoint(2)
                                if (nodeCoord == [firstPoint(2), yCoord])
                                   q(dofIndex, 1) = q(dofIndex, 1) + nbc.Flux;
                                   break;
                                end
                            end
                        end
                        break;
                    end
                end
                
            catch % In case of null node due to gap
                continue
            end
        end
    end
    
    qCalc = zeros(nDof, 1);
    
    for i = 1 : nElmY
        for j = 1 : nElmX
            
            elm = meshList{i, j};

            if isempty(elm)
                continue
            end
            
            if (meshType == "Quad")
                
                elmFirstNode = elm.FirstNode;
                elmSecondNode = elm.SecondNode;
                elmThirdNode = elm.ThirdNode;
                elmFourthNode = elm.FourthNode;
            
                elmNodeList = [elmFirstNode, elmSecondNode, elmThirdNode, elmFourthNode];
                            
                phi1 = (((x - h) * (y - h)) / (h * h));
                phi2 = -1 * (((x) * (y - h)) / (h * h));
                phi3 = (((x) * (y)) / (h * h));
                phi4 = -1 * (((x - h) * (y)) / (h * h));
                phi = [phi1, phi2, phi3, phi4];
                
                qElm = zeros(4, 1);
                
                for k = 1 : 4
                    qElmHelper = phi(k) * f;
                    qElmFirstInt = int(qElmHelper, x, 0, h);
                    qElmSecondInt = int(qElmFirstInt, y, 0, h);
%                     check = double(qElmSecondInt)
                    qElm(k, 1) = double(qElmSecondInt);
                end

                for k = 1 : 4
                   node = elmNodeList(k);                    
                   dofIndex = node.DofIndex;
                   
                   if (dofIndex <= nDof)
                        qCalc(dofIndex, 1) = qCalc(dofIndex, 1) + qElm(k, 1);
                   end
                end
                
            elseif (meshType == "Triangular")
                elmFirstNode = elm.FirstNode;
                elmSecondNode = elm.SecondNode;
                elmThirdNode = elm.ThirdNode;
                
                elmNodeList = [elmFirstNode, elmSecondNode, elmThirdNode];
                
                xCoordList = [elmFirstNode.X, elmSecondNode.X, elmThirdNode.X];
                yCoordList = [elmFirstNode.Y, elmSecondNode.Y, elmThirdNode.Y];
                
                hx = xCoordList(2) - xCoordList(1);
                hy = yCoordList(3) - yCoordList(1);
                
                area = hx * hy / 2;
                mul = 1 / (2 * area);
                
                phi1 = mul * (((xCoordList(2) * yCoordList(3)) - (xCoordList(3) * yCoordList(2))) + ((yCoordList(2) - yCoordList(3)) * x) + ((xCoordList(3) - xCoordList(2)) * y));
                phi2 = mul * (((xCoordList(3) * yCoordList(1)) - (xCoordList(1) * yCoordList(3))) + ((yCoordList(3) - yCoordList(1)) * x) + ((xCoordList(1) - xCoordList(3)) * y));
                phi3 = mul * (((xCoordList(1) * yCoordList(2)) - (xCoordList(2) * yCoordList(1))) + ((yCoordList(1) - yCoordList(2)) * x) + ((xCoordList(2) - xCoordList(1)) * y));

                phi = [phi1, phi2, phi3];
                
                qElm = zeros(3, 1);
                
                for k = 1 : 3
                    qElmHelper = phi(k) * f;
                    qElmFirstInt = int(qElmHelper, x, 0, hx);
                    qElmSecondInt = int(qElmFirstInt, y, 0, hy);                    
                    qElm(k, 1) = double(qElmSecondInt);
                end
                
                for k = 1 : 3
                   node = elmNodeList(k); 
                   dofIndex = node.DofIndex;
                   if (dofIndex <= nDof)
                        qCalc(dofIndex, 1) = qCalc(dofIndex, 1) + qElm(k, 1);
                   end                   
                end
                
            end
            
        end
    end

    fGlobal = qGiven + qCalc;
    
end