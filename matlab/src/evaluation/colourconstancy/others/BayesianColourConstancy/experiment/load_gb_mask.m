function mask = load_mask;

mask = zeros(240,360);
mask(131:end,231:end) = 1;