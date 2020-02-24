function [Wrsp,ERrsp,SDrsp,Wmv,ERmv,SDmv,Wmv_S] = resampfront(RetSeries, NumPortf, NumSimu)
% RESAMPFRONT computes the resampled efficient frontier. Weights, expected
% returns and standard deviatios, both of resampled and mean variance
% efficient portfolios, are provided as outputs. Short sell constraint is 
% imposed.
%--------------------------------------------------------------------------
% INPUTS:  RetSeries= TxNumAssets matrix collecting asset returns.
%          NumPortf= number of resampled portfolios to compute.
%          NumSimu= number of simulation to perform.
%--------------------------------------------------------------------------
% OUTPUTS: Wmv= NumAssetxNumPortf matrix collecting mean-variance portfolio
%              weights.
%          ERmv= column vector collecting mean-variance  portfolio expected 
%              returns.
%          SDmv= column vector collecting mean-variance portfolio standard 
%              deviations.
%          Wrsp= NumAsset*NumPortf matrix collecting resampled portfolio 
%              weights.
%          ERrsp= column vector collecting resampled  portfolio expected 
%              returns.
%          SDrsp= column vector collecting resampled portfolio standard 
%              deviations.
%          Wmv_S= NumAssets*NumPortf*NumSimu array collecting the simulated
%              mean variance weights (useful for statistical analysis).
%--------------------------------------------------------------------------           

T = size(RetSeries, 1); %determine time series length
NumAssets = size(RetSeries, 2); %determine number of assets
ERassets = mean(RetSeries); %compute expected returns
varcov = cov(RetSeries); %compute variance covariance matrix

% generate mean variance efficient frontier (useful for comparison)
[Wmv, ERmv, SDmv] = effront(ERassets, varcov, NumPortf);

% generate resampled efficient frontier
Wmv_S = zeros(NumAssets, NumPortf, NumSimu); %preallocate weight matrix
for i = 1:NumSimu
    RetSeries_S = mvnrnd(ERassets, varcov,T); %simulate return series
    ERassets_S = mean(RetSeries_S); %compute expexted returns
    varcov_S = cov(RetSeries_S); %compute variance covariance matrix
    Wmv_S(:,:,i)= effront(ERassets_S, varcov_S, NumPortf); %generate mv weights
end
Wrsp = mean(Wmv_S,3); %average simualted weights
ERrsp = Wrsp' * ERassets'; %evaluate resampled portfolios expected returns
SDrsp = diag(sqrt(Wrsp' * varcov *  Wrsp)); %evaluate resampled portfolios risk

%plot([SDmv,SDrsp],[ERmv',ERrsp])
