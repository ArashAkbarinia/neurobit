function MacbethImage = MacbethColourChecker( scale )
%MACBETHCOLOURCHECKER Summary of this function goes here
%   Detailed explanation goes here

Macbeth = zeros(4, 6, 3);
Macbeth(:, :, 1) = [115, 196,  93,  90, 130,  99; 220,  72, 195,  91, 160, 229;  43,  71, 176, 238, 188,   0; 245, 200, 160, 120, 83, 50];
Macbeth(:, :, 2) = [ 81, 149, 123, 108, 129, 191; 123,  92,  84,  59, 189, 161;  62, 149,  48, 200,  84, 136; 245, 201, 161, 121, 84, 50];
Macbeth(:, :, 3) = [ 67, 129, 157,  65, 176, 171;  45, 168,  98, 105,  62,  41; 147,  72,  56,  22, 150, 166; 240, 201, 161, 121, 85, 50];

Macbeth1 = kron(Macbeth(:, :, 1), ones(1, scale));
MacbethImage(:, :, 1) = kron(Macbeth1, ones(scale, 1));
Macbeth2 = kron(Macbeth(:, :, 2), ones(1, scale));
MacbethImage(:, :, 2) = kron(Macbeth2, ones(scale, 1));
Macbeth3 = kron(Macbeth(:, :, 3), ones(1, scale));
MacbethImage(:, :, 3) = kron(Macbeth3, ones(scale, 1));

MacbethImage = uint8(MacbethImage);

end
