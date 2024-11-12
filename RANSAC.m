function [ E, count ] = RANSAC( matches, normA, normB, threshold, iteration )
    xcoord1 = normA(1, :);
    ycoord1 = normA(2, :);
    xcoord2 = normB(1, :);
    ycoord2 = normB(2, :);
    E = [];
    count = 0;
    for x = 1:iteration
        matchNum = size(matches(2,:));
        random = [];
        for i = 1:5
            r = round(matchNum(2)*rand());
            if r == 0
               r = 1; 
            end
            random = [random, r];
        end
        leftInd = matches(1, random);
        rightInd = matches(2, random);
        x1 = [];
        y1 = [];
        x2 = [];
        y2 = [];
        ones = [1, 1, 1, 1, 1];
        for num = 1:5
            x1 = [x1, xcoord1(leftInd(num))];
            y1 = [y1, ycoord1(leftInd(num))];
            x2 = [x2, xcoord2(rightInd(num))];
            y2 = [y2, ycoord2(rightInd(num))];
        end
        Q1 = [x1; y1; ones];
        Q2 = [x2; y2; ones];
        E_comb = calibrated_fivepoint(Q1,Q2);

        for i = 1:size(E_comb,2)
            Etemp = E_comb(:,i);
            Etemp = reshape(Etemp, [3,3]);
            tempCount = 0;
            for j = 1:size(matches, 2)
               point1 = [xcoord1(matches(1, j)); ycoord1(matches(1, j)); 1];
               point2 = [xcoord2(matches(2, j)); ycoord2(matches(2, j)); 1];
               if abs(((point1') * Etemp * point2)) < threshold
                   tempCount = tempCount+1;
               end
            end
            if tempCount > count
               [U, ~, Vt] = svd(Etemp);
               W = [0, -1, 0; 1, 0, 0; 0, 0, 1];
               R = U * W * Vt;
               if det(R) == 1
                   E = Etemp;
                   count = tempCount;
               end
            end
        end
    end
end
