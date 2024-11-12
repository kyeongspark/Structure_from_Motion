function [ P, maxNum ] = tri( P1, P2, P3, P4, matches, normA, normB )
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
end

