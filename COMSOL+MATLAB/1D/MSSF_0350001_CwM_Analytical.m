clc

c0 = 3;
c1 = 5;
h = 1;

% resp. last time instant, time and spacial resolution
T = 100;
dt = 1;
dx = .01;

% diffusion constant
D = 1e-2;

% fourier decomposition nof terms
N = 10;

A = @(n) (2 / (n * pi) * ((-1) ^ n * c1 - c0));
l = @(n) (n * pi / h);
AA = zeros(1, N);
ll = zeros(1, N);

for i = 1 : N
    AA(i) = A(i);
    ll(i) = l(i);
end

c = @(x, t) (c0 + (c1 - c0) / h * x + sum( AA .* sin(ll .* x) .* exp(- ll .^ 2 * D * t) ));

figure();
hold on;

xrange = 0 : dx : h;
yrange = zeros(1, length(xrange));
for t = (0 : dt : T)
    for i = (1 : length(xrange))
        yrange(i) = c(xrange(i), t);
    end
    plot(xrange, yrange, 'Color', [0, 0, 0, .25]);
end

t = T;
for i = (1 : length(xrange))
    yrange(i) = c(xrange(i), t);
end
lbl1 = plot(xrange, yrange, 'Color', [0, 0, 1, 1]);

t = 0;
for i = (1 : length(xrange))
    yrange(i) = c(xrange(i), t);
end
lbl2 = plot(xrange, yrange, 'Color', [1, 0, 0, 1]);

% modo molto carino e nitido di graficare la prima e l'ultima curva
legend([ ...
    lbl1, ...
    lbl2 ...
    ], ...
    [ ...
    "t = "+string(T), ...
    "t = "+string(t) ...
    ]);