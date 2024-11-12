function [ corMatch ] = realMatches( E, matches, normA, normB, threshold )
    corMatch = [];
    for j = 1:size(matches, 2)
       point1 = [normA(1, matches(1, j)); normA(2, matches(1, j)); 1];
       point2 = [normB(1, matches(2, j)); normB(2, matches(2, j)); 1];
       if abs(((point1') * E * point2)) < threshold
           corMatch = [corMatch, [matches(1, j); matches(2, j)]];
       end
    end
end

