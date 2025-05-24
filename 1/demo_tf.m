% Piccola demo per automatizzare il calcolo delle tf per il modello della
% meccanica respiratoria (non posso fidarmi dei calcoli a mano)

syms Rc Rp Cs CL Cw Pao QA Q Qs Paw s

eqns = [ ...
    QA == Q - Qs, ...
    Qs == s * Cs * Paw, ...
    Q == 1 / Rc * (Pao - Paw), ...
    Paw == Rp * QA + (1 / CL + 1 / Cw) * 1 / s * QA
];

[A, b] = equationsToMatrix(eqns, [QA, Q, Qs, Paw]);
sol = linsolve(A, b);

tf_QA_Pao = simplify(sol(1) / Pao);
tf_VA_Pao = simplify(1 / s * tf_QA_Pao);
tf_Q_Pao = simplify(sol(2) / Pao);
tf_V_Pao = simplify(1 / s * tf_Q_Pao);

disp("QA/Pao="); pretty(tf_QA_Pao);
disp("VA/Pao="); pretty(tf_VA_Pao);
disp("Q/Pao="); pretty(tf_Q_Pao);
disp("V/Pao="); pretty(tf_V_Pao);