function err = sem(x)
    n = size(x,1)*ones(1,size(x,2));
    n = n - sum(isnan(x));
    err = nanstd(x)./sqrt(n);
end