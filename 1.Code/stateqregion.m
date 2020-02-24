function stateqregion(RetSeries, ERmv, SDmv, Wmv_S)
% STATEQREGION plots mean-variance efficient frontier and the relative
% statistical equivalence region.
%--------------------------------------------------------------------------
% INPUTS:  RetSeries= T*NumAssets matrix collecting return time series.
%          ERmv= column vector collecting mean-variance  portfolio expected 
%              returns.
%          SDmv= column vector collecting mean-variance portfolio standard 
%              deviations.
%          Wmv_S= NumAssets*NumPortf*N array collecting the simulated
%              mean variance weights (usefull for statistical analysis).
% note: ERmv, SDmv and Wmv_S are outputs of RESAMPFRONT.
%--------------------------------------------------------------------------
%OUTPUTS:  only graphical.
%--------------------------------------------------------------------------

ERassets=mean(RetSeries);
varcov=cov(RetSeries);
N=size(Wmv_S,3);
%plot statistical equivalence region
figure
hold on
for i=1:N %_S stands for 'simulated'
    ERmv_S = ERassets * Wmv_S(:,:,i); %evaluate efficient portfolios expected returns
    SDmv_S = diag(sqrt(Wmv_S(:,:,i)' * varcov * Wmv_S(:,:,i))); %evaluate risk
    plot(SDmv_S, ERmv_S, '. m','MarkerSize', 2.5) %plot the simulated effcient frontier
end

%add mean variance efficient frontier
plot(SDmv, ERmv, 'LineWidth', 2, 'Marker', 'o', 'MarkerSize', 3)
hold off
xlabel('Standard deviation')
ylabel('Expected return')
title('MV Frontier and Statistical Equivalence Region')
