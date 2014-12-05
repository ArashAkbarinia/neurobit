function conditions = PrepareConditions(connum, angles, FrontierAngles, blacknwhite, n)
%PREPARECONDITIONS Summary of this function goes here
%   Detailed explanation goes here

if connum == 1
	conditions = DoCondition1(angles, FrontierAngles, blacknwhite, n);
elseif connum == 2
    conditions = DoCondition2(angles, FrontierAngles, blacknwhite, n);
elseif connum == 3
    conditions = DoCondition3(angles, FrontierAngles, blacknwhite, n);
end

end

% FIXME: merge doconditions function together
function conditions = DoCondition1(angles, FrontierAngles, blacknwhite, n)

conditions = zeros(size(angles));
conditions(and(angles < FrontierAngles(n(1), blacknwhite), angles >= FrontierAngles(n(6), blacknwhite))) = n(1);
conditions(and(angles < FrontierAngles(n(2), blacknwhite), angles >= FrontierAngles(n(1), blacknwhite))) = n(2);
conditions(and(angles < FrontierAngles(n(3), blacknwhite), angles >= FrontierAngles(n(2), blacknwhite))) = n(3);
conditions(and(angles < FrontierAngles(n(4), blacknwhite) - 2 * pi(), angles >= 0)) = n(4);
conditions(and(angles < 2 * pi(), angles >= FrontierAngles(n(3), blacknwhite))) = n(4);
conditions(and(angles < FrontierAngles(n(5), blacknwhite), angles >= (FrontierAngles(n(4), blacknwhite)- 2 * pi()))) = n(5);
conditions(and(angles < FrontierAngles(n(6), blacknwhite), angles >= FrontierAngles(n(5), blacknwhite))) = n(6);

end

function conditions = DoCondition2(angles, FrontierAngles, blacknwhite, n)

conditions = zeros(size(angles));
conditions(and(angles < FrontierAngles(7,blacknwhite) , angles >= FrontierAngles(13,blacknwhite)))=7; %
conditions(and(angles < FrontierAngles(8,blacknwhite) , angles >= FrontierAngles(7,blacknwhite)))=8; %
conditions(and(angles < FrontierAngles(9,blacknwhite) , angles >= FrontierAngles(8,blacknwhite)))=9; %
conditions(and(angles < FrontierAngles(10,blacknwhite)- 2*pi(), angles >=  0))=10; %
conditions(and(angles < 2*pi(), angles >= FrontierAngles(9,blacknwhite)))=10; %
conditions(and(angles < FrontierAngles(11,blacknwhite) , angles >= (FrontierAngles(10,blacknwhite)- 2*pi()) ))=11; %
conditions(and(angles < FrontierAngles(12,blacknwhite) , angles >= FrontierAngles(11,blacknwhite)))=12; %
conditions(and(angles < FrontierAngles(13,blacknwhite) , angles >= FrontierAngles(12,blacknwhite)))=13; %

end

function conditions = DoCondition3(angles, FrontierAngles, blacknwhite, n)

conditions = zeros(size(angles));
conditions(and(angles < FrontierAngles(14,blacknwhite) , angles >= FrontierAngles(19,blacknwhite)))=14; %
conditions(and(angles < FrontierAngles(15,blacknwhite) , angles >= FrontierAngles(14,blacknwhite)))=15; %
conditions(and(angles < FrontierAngles(16,blacknwhite) , angles >= FrontierAngles(15,blacknwhite)))=16; %
conditions(and(angles < (FrontierAngles(17,blacknwhite)- 2*pi()) , angles >=  0        ))=17; %
conditions(and(angles <          2*pi()                 , angles >= FrontierAngles(16,blacknwhite)))=17; %
conditions(and(angles < FrontierAngles(18,blacknwhite) , angles >= (FrontierAngles(17,blacknwhite)- 2*pi()) ))=18; %
conditions(and(angles < FrontierAngles(19,blacknwhite) , angles >= FrontierAngles(18,blacknwhite)))=19; %

end
