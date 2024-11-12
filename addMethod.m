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

% This is the START of the GROWING step

colorB = imread('pictures\sfm04.jpg');
img3 = imread('pictures\sfm05.jpg');
img3 = single(rgb2gray(img3));
[fc, dc] = vl_sift(img3);
[matchXtra, scoreXtra] = vl_ubcmatch(db, dc);

matchesXYZ = [];
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
            matchesXYZ = [matchesXYZ, [matches(2,i); c(1,1); c(2,1); c(3,1)]];
        end
    end
end

supMatches = [];
for i = 1:size(matchXtra, 2)
   ind = matchXtra(1, i);
   for j = 1:size(matchesXYZ, 2)
      if ind == matchesXYZ(1,j)
         temp = [fc(1, matchXtra(2, i)); fc(2, matchXtra(2, i)); 1];
         norm = inv(K)*temp;
         supMatches = [supMatches, [norm(1,1); norm(2,1); matchesXYZ(2, j); matchesXYZ(3, j); matchesXYZ(4, j)]];
         continue
      end
   end    
end

for z = 1:7500
    input = [];
    for i = 1:3
        r = round(size(supMatches, 2)*rand());
        if r == 0
           r = 1; 
        end
        input = [input; [supMatches(1, r), supMatches(2, r), 1, supMatches(3, r), supMatches(4, r), supMatches(5, r)]];
    end

    newP = PerspectiveThreePoint(input);
    checkCount = 0;
    for j = 1:size(newP,1)/4
        tempP = newP(1+(j-1)*4:3+(j-1)*4, :);
        addCount = 0;
        for k = 1:size(supMatches, 2)
           XYZ = [supMatches(3, k); supMatches(4, k); supMatches(5, k); 1];
           xyz = tempP * XYZ;
           xyz = xyz/xyz(3,1);
           tempPoint1 = [supMatches(1,k), supMatches(2,k)];
           tempPoint2 = inv(K) * xyz;
           tempPoint2 = [tempPoint2(1,1), tempPoint2(2,1)];
           dist = (tempPoint1(1,1)-tempPoint2(1,1))*(tempPoint1(1,1)-tempPoint2(1,1));
           dist = dist + (tempPoint1(1,2)-tempPoint2(1,2))*(tempPoint1(1,2)-tempPoint2(1,2));
           if dist < 0.5
               addCount = addCount + 1;
           end
        end
        if addCount > checkCount
            addP = tempP;
            checkCount = addCount;
        end
    end
end

normC = [];
for i = 1:size(fc, 2)
   temp = [fc(1,i); fc(2,i); 1];
   temp = inv(K)*temp;
   normC = [normC, temp];
end

threshold = 0.005;
iteration = 5000;
[addE, addinCount] = RANSAC(matchXtra, normB, normC, threshold, iteration);
[corMatches] = realMatches(addE, matchXtra, normB, normC, threshold);
matchXtra = corMatches;

addcoord = coord;
addrgb = rgb;

for i = 1:size(matchXtra, 2)
    xa = normC(1, matchXtra(2, i));
    ya = normC(2, matchXtra(2, i));
    xb = normB(1, matchXtra(1, i));
    yb = normB(2, matchXtra(1, i));
    I = [1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0];
    Amat = (xa*addP(3,:) - addP(1,:));
    Amat = [Amat; (ya*addP(3,:) - addP(2,:))];
    Amat = [Amat; (xb*I(3,:) - I(1,:))];
    Amat = [Amat; (yb*I(3,:) - I(2,:))];
    
    [~, ~, V] = svd(Amat);
    c = [V(1,4)/V(4,4); V(2,4)/V(4,4); V(3,4)/V(4,4)];
    c2 = addP(1:3, 1:3) * c + addP(1:3, 4);
    if c(3,1) > 0
        if c2(3, 1) > 0
            addcoord = [addcoord, c];
            addrgb = [addrgb, colorA(round(fb(2, matchXtra(1, i))),round(fb(1, matchXtra(1, i))),:)];
        end
    end
end

ptCloud = pointCloud(transpose(addcoord));
ptCloud.Color = squeeze(addrgb);
pcwrite(ptCloud, 'InitaddMethod.ply');