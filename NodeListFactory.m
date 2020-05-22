function [nodeList, nDof, nNode, tK] = NodeListFactory(Lx, Ly, gapX1, gapX2, gapY1, gapY2, hx, hy, eBCList)

    % Generate nodes
    nx = Lx / hx; % Number of quad elements in x-dir
    ny = Ly / hy; % Number of quad elemebts in y-dir
    
    nNodeX = nx + 1; % Number of nodes in x-dir
    nNodeY = ny + 1; % Number of nodes in y-dir
    restraintList = RestraintFactory(eBCList, hx, hy);

    nodeList = cell(nNodeY, nNodeX);    
    y = 0;
    a = 1;
    dofCounter = 1;
    nNode = 0;
    for i = 1 : nNodeY
        x = 0;
        for j = 1 : nNodeX
            if gapX1 == 0
                xCond = (x >= gapX1) && (x < gapX2);
            elseif gapX2 == Lx
                xCond = (x > gapX1) && (x <= gapX2);
            else
                xCond = (x > gapX1) && (x < gapX2);
            end
            
            if gapY1 == 0
                yCond = (y >= gapY1) && (y < gapY2);
            elseif gapY2 == Ly
                yCond = (y > gapY1) && (y <= gapY2);
            else
                yCond = (y > gapY1) && (y < gapY2);
            end
            
            isInsideGap = xCond && yCond;
            
            if ~isInsideGap
                constrained = 0;
                for cntr = 1 : length(restraintList)
                    dataPtHelper = restraintList{cntr};
                    dataPt = zeros(1, 2);
                    dataPt(1, 1) = dataPtHelper(1, 1);
                    dataPt(1, 2) = dataPtHelper(1, 2);                    
                    if dataPt == [x, y]
                        constrained = 1;
                        break;
                    end
                end
                
                if (constrained)
                    node = struct('X', x, 'Y', y, 'Index', a, 'DofIndex', -1);                    
                else
                    node = struct('X', x, 'Y', y, 'Index', a, 'DofIndex', dofCounter);
                    dofCounter = dofCounter + 1;
                end                
                nodeList{i, j} = node;
                xCoordList(a) = x;
                yCoordList(a) = y;                
                a = a + 1;
                nNode = nNode + 1;
            end
            x = x + hx;
        end
        y = y + hy;
    end
    
    nDof = dofCounter - 1;    
    
    tK = zeros(nNode - nDof, 1);

    for i = 1 : nNodeY
        for j = 1 : nNodeX            
            
            node = nodeList{i, j};
            
            if (isempty(node))
                continue;
            else
                if (node.DofIndex == -1)                    
                    node.DofIndex = dofCounter;
                    dofCounter = dofCounter +  1;
                    nodeList{i, j} = node;
                    
                    for counter = 1 : length(restraintList)
                        dataPtHelper = restraintList{counter};
                        dataPt = zeros(1, 2);
                        dataPt(1, 1) = dataPtHelper(1, 1);
                        dataPt(1, 2) = dataPtHelper(1, 2);
                        temp = dataPtHelper(1, 3);
                        if dataPt == [node.X, node.Y]
                            tK(node.DofIndex - nDof, 1) = temp;
                            break;
                        end
                    end
                end                            
            end
            
        end
    end

%      scatter(xCoordList, yCoordList);
end