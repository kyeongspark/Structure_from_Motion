% Step 1: Feature Extraction & Matching
A = imread('calibration\selfmadePictures\dew02.jpg');
colorA = imread('calibration\selfmadePictures\dew02.jpg');
A = single(rgb2gray(A));
B = imread('calibration\selfmadePictures\dew03.jpg');
B = single(rgb2gray(B));
[fa, da] = vl_sift(A);
[fb, db] = vl_sift(B);
[matches, scores] = vl_ubcmatch(da, db);
K = [3384.000987415836800, 0, 2017.801473923848600; 0, 3419.296360576648600, 1449.928378966605800; 0, 0, 1];

threshold = 0.05;
iteration = 5000;
% Normalize Coordinates
[normA, normB] = normCoord(fa, fb, K);

% Step 2: Essential Matrix Estimation
[E, inCount] = RANSAC(matches, normA, normB, threshold, iteration);

% Only saving the matches that are inliers
[corMatches] = realMatches(E, matches, normA, normB, threshold);
matches = corMatches;

% Step 3
% Making four [R | t] candidates
[P1, P2, P3, P4] = deComp(E);

% Step 4 Triangulation
temp = [P1; P2; P3; P4];
maxNum = 0;
P = [];

for j = 1:4
    count1 = 0;
    count2 = 0;
    for i = 1:size(matches, 2)
        xa = normA(1, matches(1, i));
        ya = normA(2, matches(1, i));
        xb = normB(1, matches(2, i));
        yb = normB(2, matches(2, i));
        I = [1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0];
        F = temp(1+3*(j-1):3+3*(j-1), :);
        Amat = (xa*I(3,:) - I(1,:));
        Amat = [Amat; (ya*I(3,:) - I(2,:))];
        Amat = [Amat; (xb*F(3,:) - F(1,:))];
        Amat = [Amat; (yb*F(3,:) - F(2,:))];

        [~, ~, V] = svd(Amat);
        if V(3, 4) / V(4, 4) > 0
           count1 = count1 + 1;
        end
        coord = [V(1,4)/V(4,4); V(2,4)/V(4,4); V(3,4)/V(4,4)];
        coord = temp(1+3*(j-1):3+3*(j-1), 1:3) * coord + temp(1+3*(j-1):3+3*(j-1), 4);
        if coord(3, 1) > 0
            count2 = count2 + 1;
        end
    end
    if count1+count2 > maxNum
       maxNum = count1+count2;
       P = temp(1+3*(j-1):3+3*(j-1), :);
    end
end

% Get 3D coordinates
coord = [];
rgb = [];
for i = 1:size(matches, 2)
    xa = normA(1, matches(1, i));
    ya = normA(2, matches(1, i));
    xb = normB(1, matches(2, i));
    yb = normB(2, matches(2, i));
    I = [1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0];
    Amat = (xa*I(3,:) - I(1,:));
    Amat = [Amat; (ya*I(3,:) - I(2,:))];
    Amat = [Amat; (xb*P(3,:) - P(1,:))];
    Amat = [Amat; (yb*P(3,:) - P(2,:))];
    
    [~, ~, V] = svd(Amat);
    c = [V(1,4)/V(4,4); V(2,4)/V(4,4); V(3,4)/V(4,4)];
    if V(3, 4) / V(4, 4) > 0
        coord = [coord, c];
        rgb = [rgb, colorA(round(fa(2, matches(1, i))),round(fa(1, matches(1, i))),:)];
    end
end

ptCloud = pointCloud(transpose(coord));
ptCloud.Color = squeeze(rgb);
pcwrite(ptCloud, 'initSelfImage.ply');