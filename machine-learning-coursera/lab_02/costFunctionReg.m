function [J, grad] = costFunctionReg(theta, X, y, lambda)
%COSTFUNCTIONREG Compute cost and gradient for logistic regression with regularization
%   J = COSTFUNCTIONREG(theta, X, y, lambda) computes the cost of using
%   theta as the parameter for regularized logistic regression and the
%   gradient of the cost w.r.t. to the parameters. 

% Initialize some useful values
m = length(y); % number of training examples

% You need to return the following variables correctly 
J = 0;
grad = zeros(size(theta));

% ====================== YOUR CODE HERE ======================
% Instructions: Compute the cost of a particular choice of theta.
%               You should set J to the cost.
%               Compute the partial derivatives and set grad to the partial
%               derivatives of the cost w.r.t. each parameter in 

h = sigmoid(X * theta);
theta_tail =theta(2:end);
theta_appo =[0;theta_tail];
regularization = (lambda/(2*m) * (theta_tail ' * theta_tail));

J = - (1/m) * ((y' * log (h)) + ((1 - y)' * log(1 - h))) + regularization;
grad = ((1/m) * (X' *(h - y))) + ((lambda/m) * theta_appo) ;



% =============================================================

end
