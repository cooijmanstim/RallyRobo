function [y] = has_duplicate_rows(x)
  y = ~all(size(x) == size(unique(x, 'rows')));
