function PaO = PaO_wave(t, parms)
    PaO = 0;

    if(parms(1) == 0)
        amplitude = parms(2);
        frequency = parms(3);
        phase = parms(4);
        bias = parms(5);

        PaO = amplitude * sin(2 * pi * frequency * (t - phase)) + bias;
    end

    if(parms(1) == 1)
        amplitude = parms(2);
        rise_time = parms(3);
        flat_top_time = parms(4);
        flat_down_time = parms(5);
        bias = parms(6);
        phase = parms(7);

        progression = mod(t - phase, rise_time + flat_top_time + flat_down_time);
        p = progression;
        PaO = 0 + ...
            (0 <= p && p < rise_time) * (1 / rise_time * p) + ...
            (rise_time <= p && p <= rise_time + flat_top_time) * (1);
        PaO = amplitude * PaO + bias;
    end
end