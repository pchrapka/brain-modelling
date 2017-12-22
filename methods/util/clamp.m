function mat = clamp(mat, minval, maxval)
mat(mat < minval) = minval;
mat(mat > maxval) = maxval;
end