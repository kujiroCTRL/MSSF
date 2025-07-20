function J = jacobian_QA_redparms(theta, u, t)
    n = length(t);
    
    J = zeros(n, size(theta, 1));
    
    QA_base = predicted_model_QA_redparms(theta, u, t);
    
    epsilon = 1e-3;
    
    for i = 1 : size(theta, 1)
        theta_perturbed = theta;
        theta_perturbed(i) = theta(i) * (1 + epsilon);
        
        QA_perturbed = predicted_model_QA_redparms(theta_perturbed, u, t);
        
        J(:, i) = (QA_perturbed - QA_base) / (theta(i) * epsilon);
    end
end