function err = sem(x)
    err = nanstd(x)./sqrt(length(x(~isnan(x))));
end