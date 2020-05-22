function kGlobal = Assembler(meshList, kElm, meshType, nNode)
    
    nElm = size(meshList);
    nElmY = nElm(1);
    nElmX = nElm(2);

    kGlobal = zeros(nNode, nNode);
    
    if (meshType == "Quad")
        elmNode = 4;
    elseif (meshType == "Triangular")
        elmNode = 3;
    end
    
    for i = 1 : nElmY
        for j = 1 : nElmX
            elm = meshList{i, j};
        
            if isempty(elm)
                continue
            end
        
            firstNode = elm.FirstNode;
            secondNode = elm.SecondNode;
            thirdNode = elm.ThirdNode;            
                    
            firstDof = firstNode.DofIndex;
            secondDof = secondNode.DofIndex;
            thirdDof = thirdNode.DofIndex;                                    
                                   
            dofIndices = [firstDof, secondDof, thirdDof];
        
            if (meshType == "Quad")
                fourthNode = elm.FourthNode;
                fourthDof = fourthNode.DofIndex;
                dofIndices(4) = fourthDof;
            end 

            if (meshType == "Triangular")
            
                if (elm.TriangleType == "Type-1")
                    kCalc = kElm{1};
                elseif (elm.TriangleType == "Type-2")
                    kCalc = kElm{2};
                end
                
            elseif (meshType == "Quad")
                kCalc = kElm;
            end
            
            for idx1 = 1 : elmNode
                for idx2 = 1 : elmNode
                    k = kCalc(idx1, idx2);
                    dofIdx1 = dofIndices(idx1);
                    dofIdx2 = dofIndices(idx2);
                    if (dofIdx1 ~= -1) && (dofIdx2 ~= -1)
                        kGlobal(dofIdx1, dofIdx2) = kGlobal(dofIdx1, dofIdx2) + k;
                    end
                end
            end
        
        end
    end

end