function E = obj_fun(params, y, freq, Z_HF2)

% predicted output
y_pred = model_fun(params, freq, Z_HF2);

% error between model prediction and data
e=y_pred-y;

% objective function 
E=1/2*sum(e.^2);
% E=log(E+eps);

end