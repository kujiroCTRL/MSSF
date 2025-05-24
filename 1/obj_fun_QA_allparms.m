function E = obj_fun_QA_allparms(theta, measure, input, time)
% evaluate objective function value (E) corresponding to given parameter
% values (theta) in the state-space formulation of the linear lung
% mechanics model

% predicted output (output corresponding to the given guessed parameter values)
predicted_measure = predicted_model_QA_allparms(theta,input,time);

% error
e = measure - predicted_measure;
% objective function
E = 1/2 * sum(e.^2);
% E=1/2*norm(e);
end