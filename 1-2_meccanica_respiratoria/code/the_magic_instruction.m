function [] = the_magic_instruction(fn_sz, lw, ms)
    set(gca, "FontSize", fn_sz); set(findall(gca, 'Type', 'scatter'), 'LineWidth', ms); set(findall(gca, 'Type', 'line'), 'LineWidth', lw); legend;
end