#= 
        
        Creates matrix with "hot spots" for which one can apply smoothing over. 
        Goal is to identify how to draw bounding contours around these spots.

=# 

using ColorTypes: ARGB32
using Images
using ImageView: imshow

mat = Array{ARGB32}(ones(500, 500))

for i = 201:1:250, j = 201:1:250
    mat[i, j] = ARGB32(1.0, 0.0, 0.0, 1.0)
end

imshow(mat) 
