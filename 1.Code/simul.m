function [ASRmv,ASRrsp,ATOmv,ATOrsp]=simul(RetSeriesTotal,T,NumSimu,NumPortf)
% SIMUL performs out of sample simulation comparing mean variance and
% resampled efficiency. Comparison is in terms of realized Sharpe ratio and
% portfolio turnover.
%--------------------------------------------------------------------------
% INPUTS:  RetSeriesTotal= Ttotal*NumAssets matrix collecting return
%          time series. Total stands for in-sample + out-of-sample period.
%          T=  length of in-sample period used in rolling simulations.
%          NumSimu= number of simulation to perform.
%          NumPortf= number of portfolios considered in the simulation.
%--------------------------------------------------------------------------
% OUTPUTS: ASRmv= vector collecting average realized Sharpe ratios for
%          mean variance portfolios.
%          ASRrsp= vector collecting average realized Sharpe ratios for
%          resampled portfolios.
%          ATOmv= vector collecting average turnovers for mean variance
%          portfolios.
%          ATOrsp= vector collecting average turnovers for resampled
%          portfolios.
%--------------------------------------------------------------------------
% note: SIMUL uses RESAMPFRONT as auxiliary function.
%--------------------------------------------------------------------------

%compute working quantities
NumAssets=size(RetSeriesTotal,2); %number of assets
Ttotal=size(RetSeriesTotal,1); %length of total period; in + out of sample
NumRoll=Ttotal-T; %number of rolling optimization to be performed

%preallocate arrays
RRmv_cumu=zeros(1,NumPortf); %to cumulate realized returns of mv portfolios
SDmv_cumu=zeros(NumPortf,1); %to cumulate risk of mv portfolios
Wmv_minus1=zeros(NumAssets,NumPortf); %to store mv portfolio weights at time t-1
TOmv_cumu=zeros(1,NumPortf); %to cumulate turnovers of mv portfolios

RRrsp_cumu=zeros(1,NumPortf); %to cumulate realized returns of rsp portfolios
SDrsp_cumu=zeros(NumPortf,1); %to cumulate risk of rsp portfolios
Wrsp_minus1=zeros(NumAssets,NumPortf); %to store rsp portfolio weights at time t-1
TOrsp_cumu=zeros(1,NumPortf); %to cumulate turnovers of rsp portfolios

t_end=Ttotal-T+1; %end time
t_start=Ttotal; %start time
for i=1:NumRoll %start simulation: forward rolling loop.
%isolate time series and compute portfolio weights
    RetSeries=RetSeriesTotal(t_end:t_start,:);
    [Wrsp, ERrsp, SDrsp, Wmv, ERmv, SDmv] = resampfront(RetSeries, NumPortf, NumSimu);
    RRassets=RetSeriesTotal(t_end-1,:); % compute realized returns for asset classes
%mean-variance
    RRmv=RRassets*Wmv; %realized returns
    RRmv_cumu=RRmv_cumu+RRmv; %cumulate realized returns
    SDmv_cumu=SDmv_cumu+SDmv; %cumulate risks
    TOmv=sum(abs(Wmv_minus1-Wmv))/2; %turnovers
    TOmv_cumu=TOmv_cumu+TOmv; %cumulate turnovers
%resampling
    RRrsp=RRassets*Wrsp; %realized returns
    RRrsp_cumu=RRrsp_cumu+RRrsp; %cumulate realized returns
    SDrsp_cumu=SDrsp_cumu+SDrsp; %cumulate risks
    TOrsp=sum(abs(Wrsp_minus1-Wrsp))/2; %turnovers
    TOrsp_cumu=TOrsp_cumu+TOrsp; %cumulate turnovers
%set parameters for next loop
    Wmv_minus1=Wmv; 
    Wrsp_minus1=Wrsp;
    t_start=t_start-1;
    t_end=t_end-1;
end % end simulation 

% evaluate mean-variance and resampling average efficiency
                 %mean-variance
ARRmv=RRmv_cumu/NumRoll; %average realized returns
ASDmv=SDmv_cumu/NumRoll; %average risks
ASRmv=ARRmv'./ASDmv; %average realized Sharpe ratios
ATOmv=(TOmv_cumu-0.5)/(NumRoll-1); %average turnovers

                   %resampling
ARRrsp=RRrsp_cumu/NumRoll; %average realized returns
ASDrsp=SDrsp_cumu/NumRoll; %average risks
ASRrsp=ARRrsp'./ASDrsp; %average realized Sharpe ratios
ATOrsp=(TOrsp_cumu-0.5)/(NumRoll-1); %average turnovers
