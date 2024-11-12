function [ normA, normB ] = normCoord( a, b, K )
    xc1 = a(1, :);
    yc1 = a(2, :);
    xc2 = b(1, :);
    yc2 = b(2, :);
    faSize = size(a(1,:));
    fbSize = size(b(1,:));
    
    normA = [];
    normB = [];
    
    for i = 1:faSize(2)
       temp = [xc1(i); yc1(i); 1];
       normTemp = inv(K) * temp;
       normA = [normA, normTemp];
    end
    for i = 1:fbSize(2)
       temp = [xc2(i); yc2(i); 1];
       normTemp = inv(K) * temp;
       normB = [normB, normTemp];
    end
end

