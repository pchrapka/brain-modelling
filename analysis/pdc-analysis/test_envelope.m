%% test_envelope

% restoredefaultpath;

fs = 1000;
fc = 100;
fm = 15;
nperiods = 4;
samples = nperiods*fm*(fc/fm);
t = 0:(samples-1);
t = t/fs;
carrier = sin(2*pi*fc*t);
modulation = cos(2*pi*fm*t);
x = (1+modulation).*carrier;
% x = sin(2*pi*fc*t);

x_rms = sqrt(sum(x.^2,1));

x_hil = hilbert(x);

%% compare rms and hilbert
figure;
nplots = 3;
subplot(nplots,1,1);
plot(t,x);
ylabel('original');

subplot(nplots,1,2);
plot(t,x_rms);
ylabel('rms');

subplot(nplots,1,3);
plot(t,abs(x_hil)-1);
ylabel('abs(hilbert)');

figure;
hold on;
plot(t,x,'-b');
plot(t,abs(x_hil),'-r');
legend({'orig','abs(hilbert)'});

figure;
hold on;
plot(t,x,'-b');
plot(t,real(x_hil),'--g');
plot(t,imag(x_hil),'-r');
xlim([0 t(end)/4]);
legend({'orig','real','imag'});

%% compare real and imaginary

% make x non-stationary
lambda = 6;
x2 = x.*exp(-lambda.*t);

figure;
plot(t,x2);

x2_hil = hilbert(x2);

figure;
hold on;
plot(t,x2,'-b');
plot(t,abs(x2_hil),'-r');
legend({'orig','abs(hilbert)'});

figure;
hold on;
plot(t,x2,'-b');
plot(t,real(x2_hil),'--g');
plot(t,imag(x2_hil),'-r');
% xlim([0 t(end)/4]);

legend({'orig','real','imag'});

% % delay real part by N/2 samples
% n = length(x);
% if iseven(n)
%     delay_samples = n/2;
% else
%     delay_samples = (n-1)/2;
% end

% delay real part by 90 degrees
samples_per_period = fs/fc;
delay_samples = fix(samples_per_period/4);

% x_real_delay = circshift(imag(x2_hil),[0 -delay_samples]);
x_imag_delay = circshift(imag(x2_hil),[0 -delay_samples]);
figure;
hold on;
plot(t,x2,'-b');
% plot(t,x_real_delay,'--g');
% plot(t,imag(x2_hil),'-r');
% legend({'orig','real delayed','imag'});

plot(t,real(x2_hil),'-g');
plot(t,x_imag_delay,'--r');
legend({'orig','real','imag -ve delayed'});

% xlim([0 t(end)/4]);

figure;
hold on;
plot(t,x2,'-b');
plot(t,abs(x_imag_delay + real(x2)),'-r');
legend({'orig','hilbert fixed'});
