function [Wmv_S, c, Stats]=TEST_FUNZIONI
tic;
%generates random series (50 returns for 6 assets)
%RetSeries=randn(50,6);

%%if you are using matlab 7
prezzi = xlsread('D:\GianlucaPresario\CorsoMegif\Dati.xls','B2:K950');

%%if you are using matlab 6
%prezzi = xlsread('C:\GianlucaPresario\CorsoMegif\Dati.xls');
%prezzi(:,1)=[];
%prezzi(:,11)=[];


dimdata=size(prezzi);
numprezzi=dimdata(1,1); %numero di date su cui si hanno prezzi
nassets=dimdata(1,2);%numero di titoli
RetSeries=prezzi(1:numprezzi-1,:)./prezzi(2:numprezzi,:)-1;

%compute resampled frontier
NumPortf=20;
NumSimu=100;
[Wrsp,ERrsp,SDrsp,Wmv,ERmv,SDmv,Wmv_S] = resampfront(RetSeries, NumPortf, NumSimu);
size(Wrsp)
%plots confidence region
PortfSet=[1,10,20];
ConfLevel=10;
confregion(Wrsp,ERrsp,SDrsp,ERmv,SDmv,Wmv_S,RetSeries,PortfSet,ConfLevel)

%plots statistical equivalence region
stateqregion(RetSeries, ERmv, SDmv, Wmv_S)

%generates statistics
[Stats]=resampstats(Wmv, Wmv_S, Wrsp, PortfSet, ConfLevel);
nameasset=cellstr(['ENI      ';	'TIM      ';'ENEL     ';	'UNICREDIT';	'GENERALI ';	'TELECOM  ';	'BCAINTESA';	'ST MICRO ';	'AUTOSTR  ';	'SANPAOLO '])

figure(4)
for i=1:10
     subplot(5,2,i)
     hist(Wmv_S(i,1,:))
     xlabel('Simulated weigth')
     ylabel('Frequency')
     title(nameasset( i,1))
 end
toc;

%132 seconds for running on my notebook (pentium III, 1GHZ, 256 MB RAM)
%50 seconds for running on my laptop (pentium IV 2.4GHZ, 500MB RAM)