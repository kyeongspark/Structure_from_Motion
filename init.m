% Step 1: Feature Extraction & Matching
img1 = imread('pictures\sfm03.jpg');
img1 = single(rgb2gray(img1));
colorA = imread('pictures\sfm03.jpg');
img2 = imread('pictures\sfm04.jpg');
img2 = single(rgb2gray(img2));
[fa, da] = vl_sift(img1);
[fb, db] = vl_sift(img2);
[matches, scores] = vl_ubcmatch(da, db);
K = [3451.5, 0.0, 2312; 0.0, 3451.5, 1734; 0.0, 0.0, 1.0];
% threshold = 0.0002;
% iteration = 10000;
threshold = 0.0005;
iteration = 10000;

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
        Amat = (xa*F(3,:) - F(1,:));
        Amat = [Amat; (ya*F(3,:) - F(2,:))];
        Amat = [Amat; (xb*I(3,:) - I(1,:))];
        Amat = [Amat; (yb*I(3,:) - I(2,:))];

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
    Amat = (xa*P(3,:) - P(1,:));
    Amat = [Amat; (ya*P(3,:) - P(2,:))];
    Amat = [Amat; (xb*I(3,:) - I(1,:))];
    Amat = [Amat; (yb*I(3,:) - I(2,:))];
    
    [~, ~, V] = svd(Amat);
    c = [V(1,4)/V(4,4); V(2,4)/V(4,4); V(3,4)/V(4,4)];
    c2 = P(1:3, 1:3) * c + P(1:3, 4);
    if c(3,1) > 0
        if c2(3, 1) > 0
            coord = [coord, c];
            rgb = [rgb, colorA(round(fa(2, matches(1, i))),round(fa(1, matches(1, i))),:)];
        end
    end
end

ptCloud = pointCloud(transpose(coord));
ptCloud.Color = squeeze(rgb);
pcwrite(ptCloud, 'ImageInit.ply');