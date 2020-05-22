function Solver(Lx, Ly, gapX1, gapX2, gapY1, gapY2, hx, hy, k1, k2, f, EssentialBoundaryConditionList, NaturalBoundaryConditionList, meshType)

        [nodeList, nDof, nNode, tK] = NodeListFactory(Lx, Ly, gapX1, gapX2, gapY1, gapY2, hx, hy, EssentialBoundaryConditionList);
        meshList = Mesher(Lx, Ly, hx, hy, nodeList, gapX1, gapX2, gapY1, gapY2, meshType);
        kElm = ElementMatrixCalculator(meshList{1}, k1, k2, meshType);
        kGlobal = Assembler(meshList, kElm, meshType, nNode);
        fGlobal = ForceVectorAssembler(meshList, nodeList, NaturalBoundaryConditionList, nDof, f, hx, meshType);       
        
        kUU = zeros(nDof, nDof);
        kUK = zeros(nDof, nNode - nDof);
        
        kUU = kGlobal(1 : nDof, 1 : nDof);
        kUK = kGlobal(1 : nDof, nDof + 1 : nNode);
        fHelper = (kUK * tK);
        fGlobFinal = fGlobal - fHelper;
        tU = (kUU ^ -1) * fGlobFinal;
        
        tVals = zeros(nNode, 1);
        tVals(1 : nDof) = tU;
        tVals(nDof + 1 : nNode) = tK;
        
        qU = zeros(nDof - nNode, 1);
        
        % Post processor
        xCoordList = zeros(nNode, 1);
        yCoordList = zeros(nNode, 1);
        
        nodeListSize = size(nodeList);
        nNodeY = nodeListSize(1);
        nNodeX = nodeListSize(2);
        
        for i = 1 : nNodeY
            for j = 1 : nNodeX
                node = nodeList{i, j};
                if(isempty(node))
                    continue;
                else
                    xCoord = node.X;
                    yCoord = node.Y;
                    dofIdx = node.DofIndex;
                    
                    xCoordList(dofIdx, 1) = xCoord;
                    yCoordList(dofIdx, 1) = yCoord;
                    
                end                
            end
        end
        
        stem3(xCoordList, yCoordList, tVals);
end