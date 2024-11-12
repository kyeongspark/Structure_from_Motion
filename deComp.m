function [ P1, P2, P3, P4 ] = deComp( E )
    [U, ~, Vt] = svd(E);
    W = [0, -1, 0; 1, 0, 0; 0, 0, 1];
    u3 = U * [0; 0; 1];
    n3 = U * [0; 0; -1];
    P = U * W * Vt';
    P1 = [P, u3];
    P2 = [P, n3];
    P = U * W' * Vt';
    P3 = [P, u3];
    P4 = [P, n3];
end

