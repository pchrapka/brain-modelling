N = 500;
lambda = 0.99;

A = 0.0001;
gamma_sq(1) = A*lambda^(2*0);
c(1) = lambda^0;
for i=2:N
    gamma_sq(i) = gamma_sq(i-1) + A*lambda^(2*(i-1));
    c(i) = c(i-1) + lambda^(i-1);
end
gamma = sqrt(gamma_sq);

figure;
plot(1:N,gamma);

mu = gamma./c;

figure;
plot(1:N,mu);