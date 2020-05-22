function MeshList = Mesher(Lx, Ly, hx, hy, nodeList, gapX1, gapX2, gapY1, gapY2, isQuad)    

    nx = Lx / hx; % Number of quad elements in x-dir
    ny = Ly / hy; % Number of quad elemebts in y-dir
    
    if (isQuad == "Quad")
    
        % 4--------3
        % |        |
        % |        |
        % |        | 
        % 1--------2
        
        MeshList = cell(ny, nx);
        
        a = 1;
        for i = 1 : ny
            for j = 1 : nx                            
                                
                firstNode = nodeList{i, j};
                secondNode = nodeList{i, j + 1};
                thirdNode = nodeList{i + 1, j + 1};
                fourthNode = nodeList{i + 1, j};
                
                % Conditions of any node is in gap or not
                firstCond = isempty(firstNode);
                secondCond = isempty(secondNode);
                thirdCond = isempty(thirdNode);
                fourthCond = isempty(fourthNode);
                
                isAnyNodeInGap = firstCond || secondCond || thirdCond || fourthCond;                
                if ~(isAnyNodeInGap)                   
                    % Check the condition if nodes are not in gap but 
                    % element itself is in the gap by comparing geometrical
                    % center of (This condition is added to enable use mesh
                    % of any size and gap at anywhere)
                    
                    centerX = (firstNode.X + secondNode.X) / 2;
                    centerY = (firstNode.Y + secondNode.Y) / 2;
                    
                    condCenterX = (gapX1 <= centerX) && (centerX <= gapX2);
                    condCenterY = (gapY1 <= centerY) && (centerY <= gapY2);
                    
                    isCenterInGap = condCenterX && condCenterY;
                    
                    if ~isCenterInGap
                        mesh = struct('Index', a, 'FirstNode', firstNode, 'SecondNode', secondNode, 'ThirdNode', thirdNode, 'FourthNode', fourthNode);
                        MeshList{i, j} = mesh;
                        a = a + 1;
                    end                    
                end
                
            end
        end
        
    elseif (isQuad == "Triangular")
        
        %                 3_____ 2     
        %       /|3       |    /
        %      / |        |   /
        %     /  |        |  /
        %    /   |        | /
        % 1 /____|2      1|/
                
        MeshList = cell(ny, 2 * nx);
        triangleType = "Type-1";
        a = 1;
        
        for i = 1 : ny
            posCount = 1;
            for j = 1 : nx                            
                counter = 0;                                
                while (counter < 2)
                    if (counter == 0)
                        firstNode = nodeList{i, j};
                        secondNode = nodeList{i, j + 1};
                        thirdNode = nodeList{i + 1, j + 1};
                    else
                        firstNode = nodeList{i, j};
                        secondNode = nodeList{i + 1, j + 1};
                        thirdNode = nodeList{i + 1, j};                        
                    end  

                    % Conditions of any node is in gap or not
                    firstCond = isempty(firstNode);
                    secondCond = isempty(secondNode);
                    thirdCond = isempty(thirdNode);
                    
                    isAnyNodeInGap = firstCond || secondCond || thirdCond;
                    if ~(isAnyNodeInGap)
                        % Check the condition if nodes are not in gap but
                        % element itself is in the gap by comparing geometrical
                        % center of (This condition is added to enable use mesh
                        % of any size and gap at anywhere)
                        
                        centerX = (firstNode.X + secondNode.X + thirdNode.X) / 3;
                        centerY = (firstNode.Y + secondNode.Y + thirdNode.Y) / 3;
                        
                        condCenterX = (gapX1 <= centerX) && (centerX <= gapX2);
                        condCenterY = (gapY1 <= centerY) && (centerY <= gapY2);
                        
                        isCenterInGap = condCenterX && condCenterY;
                        
                        if ~isCenterInGap
                            mesh = struct('Index', a, 'FirstNode', firstNode, 'SecondNode', secondNode, 'ThirdNode', thirdNode, 'TriangleType', triangleType);
                            MeshList{i, posCount} = mesh;
                            posCount = posCount + 1;
                            a = a + 1;
                            counter = counter + 1;
                            if (triangleType == "Type-1")
                                triangleType = "Type-2";
                            else
                                triangleType = "Type-1";
                            end
                        else
                            counter = counter + 1;    
                        end
                    else
                        counter = counter + 1;
                    end
                end
            end
        end
        
    end
end










