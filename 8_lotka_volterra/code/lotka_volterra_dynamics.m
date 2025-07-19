function dX = lotka_volterra_dynamics(t, X, parms)
    x = X(1);
    y = X(2);

    alpha = parms(1);
    beta = parms(2);
    gamma = parms(3);
    delta = parms(4);

    dx = alpha * x - beta * x * y;
    dy = - gamma * y + delta * x * y;

    dX = [dx; dy];
end