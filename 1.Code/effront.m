function [Wmv,ERmv,SDmv] = effront(ERassets, varcov, NumPortf)
% EFFRONT computes the mean variance efficient frontier. Weights, expected
% returns and standard deviations of a set of efficient portfolios are  
% provided as outputs. Short sell constraint is imposed.
%--------------------------------------------------------------------------
% INPUTS:  ERassets= row vector of asset expected returns.
%          varcov= variance covariance matrix of asset returns.
%          NumPortf= number of efficient portfolios to compute.
%--------------------------------------------------------------------------
% OUTPUTS: Wmv= NumAsset*NumPortf matrix of efficient portfolio weights.
%          ERmv= column vector of efficient portfolio expected returns.
%          SDmv= column vector of efficient portfolio standard deviations.
%--------------------------------------------------------------------------           

%get number of assets
NumAssets = length(ERassets); 

% find maximum expected return.
ERmax = max(ERassets);

% set constraints
Aeq=ones(1,NumAssets);
beq=1;
lb=zeros(NumAssets,1);
   
% find minimum expected return,i.e.,global minimum variance portfolio expected return.
options = optimset('display', 'off','largescale', 'off'); %set optimisation options
Wgmv = quadprog(varcov, [], [], [], Aeq, beq, lb, [], [], options); 
ERgmv = ERassets * Wgmv;

%compute expected return range partition
ERmv = linspace(ERgmv,ERmax,NumPortf);
%redefine constraints
Aeq = [Aeq; ERassets]; 
beq = [ones(1, NumPortf); ERmv];
%preallocate arrays
Wmv = zeros(NumAssets, NumPortf); 
SDmv = zeros(NumPortf, 1);
%generate efficient frontier using standard algorithm
for i=1 : NumPortf
    % compute target portfolio weights
    Wmv(:,i) = quadprog(varcov, [], [], [], Aeq, beq(:,i), lb, [], [] , options);
    %compute target portfolio standard deviation
    SDmv(i,:) = sqrt(Wmv(:,i)'* varcov * Wmv(:,i));
end

%plot(SDmv,ERmv,'-o')
%xlabel('Standard deviation')
%ylabel('Expected return')