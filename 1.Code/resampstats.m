function [Stats]=resampstats(Wmv, Wmv_S, Wrsp, PortfSet, ConfLevel)
% RESAMPSTATS generates a stucture array containing statistics about the
% distribution of a set of resampled portfolio weights.
%--------------------------------------------------------------------------
% INPUTS:  Wmv= NumAsset*NumPortf matrix collecting mean-variance portfolio
%              weights.
%          Wmv_S= NumAssets*NumPortf*N array collecting the simulated
%              mean variance weights (the base for statistical analysis).
%          Wrsp= NumAsset*NumPortf matrix collecting resampled portfolio 
%              weights.
%          PortfSet= row vector collecting rank numbers of a set of
%          resampled portfolios. You can select entire resampled set
%          (PortfSet=[1:NumPortf]), or just a subset. Statistics are
%          computed for all and only the resampled portfolios specified in
%          PortfSet.
%          ConfLevel= scalar defining the level of confidence to use in
%          computing upper percentile. Possible values are from 0 to 100.
%--------------------------------------------------------------------------
% OUTPUTS: Stats= structure array collecting : ranks, mean variance and
% resampled weights, standard errors, skewness, kurtosis and percentiles.
%--------------------------------------------------------------------------

% ceck inputs
NumPortf=size(Wrsp,2);
if max(PortfSet)>NumPortf
    error('exceeded maximum portfolio rank')
end
% build Stats structure
for i=1:length(PortfSet)
    j=PortfSet(i);
    Stats(i).portf_rank=num2str(j); %field 1: portfolios rank
    Stats(i).MvWeights=Wmv(:,j)'; %filed 2: mean-variance weights
    Stats(i).ResampWeights=Wrsp(:,j)'; %field 3: resampled weights
    Wmv_S2D=permute(Wmv_S(:,j,:),[3,1,2]);
    Stats(i).StandErr=std(Wmv_S2D); %field 4: standard errors
    Stats(i).Skewness=skewness(Wmv_S2D); %field 5: skewness
    Stats(i).Kurtosis=kurtosis(Wmv_S2D); %field 6: kurtosis
    Stats(i).Median=median(Wmv_S2D); %field 7: median
    Stats(i).LowPercentile=prctile(Wmv_S2D,(100-ConfLevel)); %field 8: lower percentile
    Stats(i).UpPercentile=prctile(Wmv_S2D,ConfLevel); %field 9: upper percentile
end

