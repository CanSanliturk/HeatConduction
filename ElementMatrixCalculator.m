function kElm = ElementMatrixCalculator(elm, K1, K2, elmType)
    
    syms x y;
    
    if (elmType == "Quad")
    
        kElm = zeros(4, 4);
    
        xCoordList = zeros(4, 1);
        yCoordList = zeros(4, 1);
    
        xCoordList(1) = elm.FirstNode.X;
        xCoordList(2) = elm.SecondNode.X;
        xCoordList(3) = elm.ThirdNode.X;
        xCoordList(4) = elm.FourthNode.X;
    
        yCoordList(1) = elm.FirstNode.Y;
        yCoordList(2) = elm.SecondNode.Y;
        yCoordList(3) = elm.ThirdNode.Y;
        yCoordList(4) = elm.FourthNode.Y;
    
        hx = xCoordList(2) - xCoordList(1);
        hy = yCoordList(4) - yCoordList(1);

        phi1 = (((x - hx) * (y - hy)) / (hx * hy));
        phi2 = -1 * (((x) * (y - hy)) / (hx * hy));
        phi3 = (((x) * (y)) / (hx * hy));
        phi4 = -1 * (((x - hx) * (y)) / (hx * hy));
    
        phi = [phi1, phi2, phi3, phi4];
    
        for i = 1 : 4
            phix(i) = diff(phi(i), x);
            phiy(i) = diff(phi(i), y);
            D(1, i) = phix(i);
            D(2, i) = phiy(i);
        end
    
        DT = D';
        kMat = zeros(2, 2);
        kMat(1, 1) = K1;
        kMat(2, 2) = K2;
        helper = DT * kMat * D;
    
        kHelper = int(int(helper, x, 0, hx), y, 0, hy);
    
        for i = 1 : 4
            for j = 1 : 4
                kElm(i, j) = vpa(kHelper(i, j));
            end
        end
    
    elseif (elmType == "Triangular")
        kElm = cell(2, 1); % Restores two elm matrix for two different 
        % triangular types. For type-1 triangular and type-2 triangular
        
        xCoordList(1) = elm.FirstNode.X;
        xCoordList(2) = elm.SecondNode.X;
        xCoordList(3) = elm.ThirdNode.X;
    
        yCoordList(1) = elm.FirstNode.Y;
        yCoordList(2) = elm.SecondNode.Y;
        yCoordList(3) = elm.ThirdNode.Y;
    
        hx = xCoordList(2) - xCoordList(1);
        hy = yCoordList(3) - yCoordList(1);
         
        area = hx * hy / 2;
        mul = 1 / (2 * area);

        % Type 1
        xA = [0 hx hx];
        yA = [0 0 hy];
        phi1A = mul * (((xA(2) * yA(3)) - (xA(3) * yA(2))) + ((yA(2) - yA(3)) * x) + ((xA(3) - xA(2)) * y));
        phi2A = mul * (((xA(3) * yA(1)) - (xA(1) * yA(3))) + ((yA(3) - yA(1)) * x) + ((xA(1) - xA(3)) * y));
        phi3A = mul * (((xA(1) * yA(2)) - (xA(2) * yA(1))) + ((yA(1) - yA(2)) * x) + ((xA(2) - xA(1)) * y));

        % Type 2
        xB = [0 hx 0];
        yB = [0 hy hy];
        phi1B = mul * (((xB(2) * yB(3)) - (xB(3) * yB(2))) + ((yB(2) - yB(3)) * x) + ((xB(3) - xB(2)) * y));
        phi2B = mul * (((xB(3) * yB(1)) - (xB(1) * yB(3))) + ((yB(3) - yB(1)) * x) + ((xB(1) - xB(3)) * y));
        phi3B = mul * (((xB(1) * yB(2)) - (xB(2) * yB(1))) + ((yB(1) - yB(2)) * x) + ((xB(2) - xB(1)) * y));


        phiA = [phi1A phi2A phi3A];
        phiB = [phi1B phi2B phi3B];

        kElmTypeOne = zeros(3, 3);
        kElmTypeTwo = zeros(3, 3);

        for i = 1 : 3
            for j = 1 : 3                               
                % elmA
                phiAix = diff(phiA(i), x);
                phiAjx = diff(phiA(j), x);

                phiAiy = diff(phiA(i), y);
                phiAjy = diff(phiA(j), y);

                helperOneA = phiAjx * K1 * phiAix;
                helperTwoA = phiAjy * K2 * phiAiy;
                helperFinalA = helperOneA + helperTwoA;

                stepOneA = int(helperFinalA, x, 0, hx);
                stepTwoA = int(stepOneA, y, 0, hy);

                kHelperA = double(stepTwoA);

                kElmTypeOne(i, j) = kElmTypeOne(i, j) + kHelperA;

                %elmB
                phiBix = diff(phiB(i), x);
                phiBjx = diff(phiB(j), x);

                phiBiy = diff(phiB(i), y);
                phiBjy = diff(phiB(j), y);

                helperOneB = phiBjx * K1 * phiBix;
                helperTwoB = phiBjy * K2 * phiBiy;
                helperFinalB = helperOneB + helperTwoB;

                stepOneB = int(helperFinalB, x, 0, hx);
                stepTwoB = int(stepOneB, y, 0, hy);

                kHelperB = double(stepTwoB);

                kElmTypeTwo(i, j) = kElmTypeTwo(i, j) + kHelperB;
            end
        end
        
        
        % Return value
        kElm{1, 1} = kElmTypeOne;
        kElm{2, 1} = kElmTypeTwo;                

    end

end