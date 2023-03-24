

Thr = [0 0.01];
figure(1); clf;
for iR=1:length(Thr)
    H0 = nan(30000,1); for iT=1:30000; k = V1(iT,:) > Thr(iR); H0(iT)= -sum(V1(iT,k).*log10(V1(iT,k))); end
    H = histcn(df.run_trial,1:50,'AccumData',H0,'fun',@nanmean);
    dH = histcn(df.run_trial,1:50,'AccumData',H0,'fun',@nanstderr);
    errorbar(1:50,H,dH,dH,'.-','linewidth',2);
    hold on;
end

legend('p>0','p>0.01');