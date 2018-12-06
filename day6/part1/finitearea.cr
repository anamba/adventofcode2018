class Point
  property x : Int32
  property y : Int32
  property finite = true
  property area = 1

  def initialize(@x, @y)
  end

  def distance_to(b)
    (x - b.x).abs + (y - b.y).abs
  end
end

inputs = Array(Point).new
while (str = gets)
  if str =~ /^(\d+),\s(\d+)$/
    inputs << Point.new($1.to_i, $2.to_i)
  else
    puts "Malformed input #{str}"
    exit
  end
end

# disqualify the outermost points, which will certainly have infinite areas
xs = inputs.map(&.x)
ys = inputs.map(&.y)
x_lower_bound = xs.min
x_upper_bound = xs.max
y_lower_bound = ys.min
y_upper_bound = ys.max

inputs.each { |p| p.finite = p.x > x_lower_bound && p.x < x_upper_bound && p.y > y_lower_bound && p.y < y_upper_bound }

finite = inputs.select(&.finite)

finite.each do |p|
  x_min = p.x
  x_max = p.x
  y_min = p.y
  y_max = p.y

  puts "Calculating area for #{p.x}, #{p.y}"
  cycles = 0

  loop do
    area = 0

    # work outward, keep expanding until we turn up nothing new
    x_min -= 1
    x_max += 1
    y_min -= 1
    y_max += 1

    # trace a square around our position
    [y_min, y_max].each do |y|
      (x_min..x_max).each do |x|
        test = Point.new(x, y)

        # us vs everyone else
        if p.distance_to(test) < (inputs - [p]).map { |b| b.distance_to(test) }.min
          # puts "Closer than everyone else, claiming it!"
          area += 1
        end
      end
    end
    [x_min, x_max].each do |x|
      (y_min + 1..y_max - 1).each do |y|
        test = Point.new(x, y)

        # us vs everyone else
        if p.distance_to(test) < (inputs - [p]).map { |b| b.distance_to(test) }.min
          # puts "Closer than everyone else, claiming it!"
          area += 1
        end
      end
    end

    break if area == 0
    p.area += area

    # not the greatest way to check for infinite area, but given our dataset, it'll do
    cycles += 1
    if cycles > 100
      p.finite = false
      break
    end
  end
end

pp finite.select(&.finite).sort { |a, b| a.area <=> b.area }
