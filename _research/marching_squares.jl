using Luxor

width = 500
height = 500

nrows = 10
ncols = 10

step_x = width / ncols
step_y = height / nrows

points = Array{NamedTuple}(undef, nrows, ncols)

Drawing(width, height, "/home/src/Projects/neuriviz/assets/squares.png");
background("gray")

origin(Point(-25, -25))

function iso_line(case_value, north, east, south, west)
    if case_value == 0 || case_value == 15
    elseif case_value == 1
        line(west, south, :stroke)
    elseif case_value == 2
        line(south, east, :stroke)
    elseif case_value == 3 || case_value == 12
        line(east, west, :stroke)
    elseif case_value == 4 || case_value == 11
        line(north, east, :stroke)
    elseif case_value == 5
        line(north, west, :stroke)
        line(south, east, :stroke)
    elseif case_value == 6 || case_value == 9
        line(north, south, :stroke)
    elseif case_value == 7 || case_value == 8
        line(north, west, :stroke)
    elseif case_value == 10
        line(north, east, :stroke)
        line(south, west, :stroke)
    elseif case_value == 13
        line(east, south, :stroke)
    elseif case_value == 14
        line(west, south, :stroke)
    end
end

iso_value(a, b, c, d) = a * 8 + b * 4 + c * 2 + d * 1

for j = 1:nrows
    for i = 1:ncols
        cvalue = rand([0, 1])
        cvalue == 0 ? sethue("white") : sethue("black")
        pos = Point(step_x * i, step_y * j)
        circle(pos, 5, :fill)
        points[j, i] = (x = pos.x, y = pos.y, val = cvalue)
    end
end

sethue("black")
for j = 1:(nrows - 1)
    for i = 1:(ncols - 1)
        a = points[i, j]
        b = points[i, j + 1]
        c = points[i + 1, j + 1]
        d = points[i + 1, j]

        north = Point((b.x + a.x) / 2, a.y)
        east = Point(b.x, (b.y + c.y) / 2)
        south = Point((b.x + a.x) / 2, c.y)
        west = Point(a.x, (a.y + d.y) / 2)
	
	circle(north, 2, :fill)
	circle(east, 2, :fill)
	circle(south, 2, :fill)
	circle(west, 2, :fill)

	case = iso_value(a.val, b.val, c.val, d.val)

	fontsize(14)
	textcentered(string(case), Point((a.x + c.x) / 2, (a.y + c.y) / 2))
	
	iso_line(case, north, east, south, west)
    end
end

finish()
