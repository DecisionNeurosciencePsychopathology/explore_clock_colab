% 2022-09-23 AndyP
% PETH of RT around trial 1 'reversals' from IEV->DEV or DEV->IEV
% separately

dataset = 'BSOC';

uS = unique(df.id);
nS = length(uS);

uR = unique(df.scanner_run);
nR = length(unique(df.scanner_run));


if strcmp(dataset,'BSOC')

trial0 = nan(height(df),1);
for iS=1:nS
    for iR=1:nR
        idx = df.id==uS(iS) & df.scanner_run==iR;
        trial0(idx) = 1:sum(idx);
    end
end


I2D = nan(25+25+1,nS*nR);
D2I = nan(25+25+1,nS*nR);
D2D = nan(25+25+1,nS*nR);
I2I = nan(25+25+1,nS*nR);
iA = 1; iB = 1; iC = 1; iD = 1;
for iS=1:nS
    for iR=1:nR
        idx = df.id==uS(iS) & df.scanner_run==iR;
        rt = df.rt_csv(idx);
        rewFunc = string(df.rewFunc(idx));
        run_trial = df.run_trial(idx);
        trial = trial0(idx);
        
        firstT = find(run_trial==1 & trial~=1);
        
        % get window around firstT's for each CHANGE in contingency
        for iT = 1:length(firstT)
            rt0 = rt(firstT(iT)-25:min(firstT(iT)+25,length(rt)));
            if strcmp(rewFunc(firstT(iT)-1),'IEV') && strcmp(rewFunc(firstT(iT)),'DEV') % IEV->DEV
                I2D(1:length(rt0),iA) = rt0;
                iA = iA+1;
            elseif strcmp(rewFunc(firstT(iT)-1),'DEV') && strcmp(rewFunc(firstT(iT)),'IEV') % IEV->DEV
                D2I(1:length(rt0),iB) = rt0;
                iB = iB+1;
            elseif strcmp(rewFunc(firstT(iT)-1),'IEV') && strcmp(rewFunc(firstT(iT)),'IEV') % IEV->IEV
                I2I(1:length(rt0),iC) = rt0;
                iC = iC+1;
            elseif strcmp(rewFunc(firstT(iT)-1),'DEV') && strcmp(rewFunc(firstT(iT)),'DEV') % DEV->DEV
                D2D(1:length(rt0),iD) = rt0;
                iD = iD+1;
            else
                warning('something else');
            end
        end
    end
end

elseif strcmp(dataset,'EXP')
end

F = figure(1); clf;
errorbar(-25:1:25,nanmean(D2I,2),nanstderr(D2I'),nanstderr(D2I'),'.-','linewidth',2,'markersize',20);
hold on;
errorbar(-25:1:25,nanmean(I2D,2),nanstderr(I2D'),nanstderr(I2D'),'.-','linewidth',2,'markersize',20);
errorbar(-25:1:25,nanmean(I2I,2),nanstderr(I2I'),nanstderr(I2I'),'.-','linewidth',2,'markersize',20);
errorbar(-25:1:25,nanmean(D2D,2),nanstderr(D2D'),nanstderr(D2D'),'.-','linewidth',2,'markersize',20);
legend('D2I','I2D','I2I','D2D');
set(gca,'fontsize',24);
xlabel('time peri switch');    
ylabel('RT (ms)');        
    