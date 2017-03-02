%% test_envelope

restoredefaultpath;

fs = 1000;
fc = 100;
fm = 15;
nperiods = 4;
t = 0:(nperiods*fc-1);
t = t/fs;
carrier = sin(2*pi*fc*t);
modulation = cos(2*pi*fm*t);
x = (1+modulation).*carrier;
% x = sin(2*pi*fc*t);

x_rms = sqrt(sum(x.^2,1));

x_hil = hilbert(x);

nplots = 3;
subplot(nplots,1,1);
plot(t,x);

subplot(nplots,1,2);
plot(t,x_rms);

subplot(nplots,1,3);
plot(t,abs(x_hil)-1);