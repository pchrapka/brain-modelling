%% exp16_tnwl_weight

close all;

a = 1.8;
mu = 0.2;
x = linspace(0,1,1000);

u1 = (x - mu >= 0);
u2 = (mu - x >= 0);
wx = max(a*mu - x,0)/((a-1)*mu).*u1 + u2;

figure;
plot(x,wx);
title('wx');

figure;
plot(x,u1);
title('u1');

figure;
plot(x,u2);
title('u2');