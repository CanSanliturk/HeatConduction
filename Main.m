clear
clc
tic
% Geometry
Lx = 100;
Ly = 40;
gapX1 = 0; % Start coordinate of gap in x-dir
gapX2 = 0; % End coordinate of gap in x-dir
gapY1 = 0; % Start coordinate of gap in y-dir
gapY2 = 0; % End coordinat e of gap in y-dir

% Mesh size
h = 2;

% Material properties
k1 = 1;
k2 = 5;
f = 1e-3;

% Essential Boundary Conditions on primary variable
ebc1 = struct('FirstPointCoord', [0, 40], 'SecondPointCoord', [40, 40], 'Temp', 1);
ebc2 = struct('FirstPointCoord', [60, 40], 'SecondPointCoord', [100, 40], 'Temp', 0);

essentialBoundaryConditionList = cell(2, 1);
essentialBoundaryConditionList{1, 1} = ebc1;
essentialBoundaryConditionList{2, 1} = ebc2;

% snapnow;
% Natural Boundary Conditions on secondary variable
nbc1 = struct('FirstPointCoord', [0, 0], 'SecondPointCoord', [100, 0], 'Flux', 0);
nbc2 = struct('FirstPointCoord', [100, 0], 'SecondPointCoord', [100, 40], 'Flux', 0);
nbc3 = struct('FirstPointCoord', [0, 0], 'SecondPointCoord', [0, 40], 'Flux', 0);
nbc4 = struct('FirstPointCoord', [gapX1, gapY2], 'SecondPointCoord', [gapX1, gapY1], 'Flux', 0);
nbc5 = struct('FirstPointCoord', [gapX1, gapY1], 'SecondPointCoord', [gapX2, gapY1], 'Flux', 0);
nbc6 = struct('FirstPointCoord', [gapX2, gapY1], 'SecondPointCoord', [gapX2, gapY2], 'Flux', 0);

naturalBoundaryConditionList = cell(6, 1);
naturalBoundaryConditionList{1, 1} = nbc1;
naturalBoundaryConditionList{2, 1} = nbc2;
naturalBoundaryConditionList{3, 1} = nbc3;
naturalBoundaryConditionList{4, 1} = nbc4;
naturalBoundaryConditionList{5, 1} = nbc5;
naturalBoundaryConditionList{6, 1} = nbc6;

Solver(Lx, Ly, gapX1, gapX2, gapY1, gapY2, h, h, k1, k2, f, essentialBoundaryConditionList, naturalBoundaryConditionList, "Quad");
% Solver(Lx, Ly, gapX1, gapX2, gapY1, gapY2, h, h, k1, k2, f, essentialBoundaryConditionList, naturalBoundaryConditionList, "Triangular");
toc

