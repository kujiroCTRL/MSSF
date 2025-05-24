function dGX = glucose_minimal_model(t, GX, t_array, I_array, parms)
    G = GX(1);
    X = GX(2);
    
    Sg = parms(1);
    Gb = parms(2);
    k = parms(3);
    Si = parms(4);
    Ib = parms(5);
    
    I = interp1(t_array, I_array, t);

    dG = Sg * (Gb - G) - X * G;
    dX = k * (Si * (I - Ib) - X);

    dGX = [dG; dX];
end