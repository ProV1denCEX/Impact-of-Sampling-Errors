function confregion(Wrsp,ERrsp,SDrsp,ERmv,SDmv,Wmv_S,RetSeries,PortfSet,ConfLevel)
% CONFREGION plots X% confidence region for a set of resampled portfolios
%--------------------------------------------------------------------------
% INPUTS:  Wmv= NumAsset*NumPortf matrix collecting mean-variance portfolio
%              weights.
%              deviations.
%          Wrsp= NumAsset*NumPortf matrix collecting resampled portfolio 
%              weights.
%          ERrsp= column vector collecting resampled  portfolio expected 
%              returns.
%          SDrsp= column vector collecting resampled portfolio standard 
%              deviations.
%          ERmv= column vector collecting mean-variance  portfolio expected 
%              returns.
%          SDmv= column vector collecting mean-variance portfolio standard 
%              deviations
%          Wmv_S= NumAssets*NumPortf*N array collecting the simulated
%              mean variance weights (usefull for statistical analysis).
%          RetSeries= T*NumAssets matrix collecting return time series.
%          PortfSet= row vector collecting the rank numbers of the
%          resampled portfolios of which confidece region is to be plot;
%          maximum size allowed is 6.
%          ConfLevel= scalar between 0 and 100 defining the level of confidence desired.
%--------------------------------------------------------------------------
% OUTPUTS: only graphical.
%--------------------------------------------------------------------------
        
% ceck inputs
NumPortf=size(Wrsp,2);
if max(PortfSet)>NumPortf
    error('exceeded maximum portfolio rank')
elseif length(PortfSet)>6
    error('maximum number of portfolios is 6')
end
        
% plot mean variance and resampled efficient frontier
figure
hold on
plot(SDmv, ERmv,...
    'LineWidth', 1, 'Marker', 'o', 'MarkerSize', 3, 'MarkerEdgeColor', 'b')
plot(SDrsp, ERrsp,...
    'Color', 'm', 'LineWidth', 1, 'Marker', 'o', 'MarkerSize', 3, 'MarkerEdgeColor', 'm')
xlabel('Standard deviation')
ylabel('Expected return')
title('MV Frontier, Resampled Frontier and X% confidence region')

% compute tracking errors
varcov=cov(RetSeries);
N=size(Wmv_S,3);
for i=1:N
    deltaW=Wmv_S(:,:,i)-Wrsp;
    te(i,:)=diag(deltaW'*varcov*deltaW)';
end

% compute ConfLevel% percentiles
pc=prctile(te, ConfLevel);

% isolate and plot portfolios that belongs to confidence region
ERassets=mean(RetSeries);
colorString=char('r','g','c','k','m','b');
colorIndicator=1;
for i=PortfSet             
    ERstore=[]; %preallocate storing arrays
    SDstore=[];
    teIn=find(te(:,i)<=pc(i)); %find acceptable tracking errors
    numIn=length(teIn); %define length of nested loop
    Wpi_S=Wmv_S(:,i,:); %extract all simulated portfolios of rank i
    Wpi_S_In=Wpi_S(:,:,teIn); %select those with acceptable track.error
    for j=1:numIn
        ERpi_In=ERassets*Wpi_S_In(:,:,j); %compute expected ret for selected portf.
        ERstore=[ERstore,ERpi_In]; %store expected returns
        SDpi_In=diag(sqrt(Wpi_S_In(:,:,j)'*varcov*Wpi_S_In(:,:,j))); %compute risk
        SDstore=[SDstore,SDpi_In];  %store risk  
    end
    plot(SDstore,ERstore,... %plot (risk,return)
        '.','MarkerSize',5,'Markeredgecolor',colorString(colorIndicator))
    colorIndicator=colorIndicator+1;
end
