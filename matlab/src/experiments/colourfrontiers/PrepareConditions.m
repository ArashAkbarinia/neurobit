function conditions = PrepareConditions(connum, angles, FrontierTable, blacknwhite, n)
%PREPARECONDITIONS Summary of this function goes here
%   Detailed explanation goes here

% there is a plus 3 because angles start from column 3.
blacknwhite = blacknwhite + 3;

if connum == 1
	conditions = DoCondition1(angles, FrontierTable, blacknwhite, n);
elseif connum == 2
    conditions = DoCondition2(angles, FrontierTable, blacknwhite, n);
elseif connum == 3
    conditions = DoCondition3(angles, FrontierTable, blacknwhite, n);
end

end

% FIXME: merge doconditions function together
function conditions = DoCondition1(angles, FrontierTable, blacknwhite, n)

conditions = zeros(size(angles));
conditions(and(angles < FrontierTable{n(1), blacknwhite}, angles >= FrontierTable{n(6), blacknwhite})) = n(1);
conditions(and(angles < FrontierTable{n(2), blacknwhite}, angles >= FrontierTable{n(1), blacknwhite})) = n(2);
conditions(and(angles < FrontierTable{n(3), blacknwhite}, angles >= FrontierTable{n(2), blacknwhite})) = n(3);
conditions(and(angles < FrontierTable{n(4), blacknwhite} - 2 * pi(), angles >= 0)) = n(4);
conditions(and(angles < 2 * pi(), angles >= FrontierTable{n(3), blacknwhite})) = n(4);
conditions(and(angles < FrontierTable{n(5), blacknwhite}, angles >= (FrontierTable{n(4), blacknwhite}- 2 * pi()))) = n(5);
conditions(and(angles < FrontierTable{n(6), blacknwhite}, angles >= FrontierTable{n(5), blacknwhite})) = n(6);

end

function conditions = DoCondition2(angles, FrontierTable, blacknwhite, n)

conditions = zeros(size(angles));
conditions(and(angles < FrontierTable{7,blacknwhite} , angles >= FrontierTable{13,blacknwhite}))=7; %
conditions(and(angles < FrontierTable{8,blacknwhite} , angles >= FrontierTable{7,blacknwhite}))=8; %
conditions(and(angles < FrontierTable{9,blacknwhite} , angles >= FrontierTable{8,blacknwhite}))=9; %
conditions(and(angles < FrontierTable{10,blacknwhite}- 2*pi(), angles >=  0))=10; %
conditions(and(angles < 2*pi(), angles >= FrontierTable{9,blacknwhite}))=10; %
conditions(and(angles < FrontierTable{11,blacknwhite} , angles >= (FrontierTable{10,blacknwhite}- 2*pi()) ))=11; %
conditions(and(angles < FrontierTable{12,blacknwhite} , angles >= FrontierTable{11,blacknwhite}))=12; %
conditions(and(angles < FrontierTable{13,blacknwhite} , angles >= FrontierTable{12,blacknwhite}))=13; %

end

function conditions = DoCondition3(angles, FrontierTable, blacknwhite, n)

conditions = zeros(size(angles));
conditions(and(angles < FrontierTable{14,blacknwhite} , angles >= FrontierTable{19,blacknwhite}))=14; %
conditions(and(angles < FrontierTable{15,blacknwhite} , angles >= FrontierTable{14,blacknwhite}))=15; %
conditions(and(angles < FrontierTable{16,blacknwhite} , angles >= FrontierTable{15,blacknwhite}))=16; %
conditions(and(angles < (FrontierTable{17,blacknwhite}- 2*pi()) , angles >=  0        ))=17; %
conditions(and(angles <          2*pi()                 , angles >= FrontierTable{16,blacknwhite}))=17; %
conditions(and(angles < FrontierTable{18,blacknwhite} , angles >= (FrontierTable{17,blacknwhite}- 2*pi()) ))=18; %
conditions(and(angles < FrontierTable{19,blacknwhite} , angles >= FrontierTable{18,blacknwhite}))=19; %

end
