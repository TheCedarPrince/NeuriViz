#= 

        Creates a matrix of raw noise.
        Thanks to Cormullion for this example!

=#

using Luxor, Colors, Images, ImageFiltering, ImageView

m = @imagematrix begin
    background("black")
    t = Tiler(400, 400, 400, 400)
    for (pos, n) in t
        sethue(HSB(360 * noise(t.currentrow * 0.009, t.currentcol * 0.009), 0.8, 0.8))
        box(pos, 1, 1, :fillstroke)
    end
end 400 400

function convertmatrixtocolors(m)
    return convert.(Colors.RGBA, m)
end

img = convertmatrixtocolors(m)
imshow(img)
