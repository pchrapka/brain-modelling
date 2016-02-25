%% house_test.m

%% vector example
x = randi([-10 10],10,1)
[v,b] = house(x)

P = eye(length(x),length(x)) - b*v*v'

Px = P*x

%% matrix example
X = randi([-10 10],5,5)
[v,b] = house(X(:,2))

w = b*X'*v;
PX = X - v*w'

%% matrix example 2
X = randi([-10 10],5,5)
[v,b] = house(X(2,:))

w = b*X*v;
XP = X - w*v'
