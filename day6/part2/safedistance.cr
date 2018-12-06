struct Point
  property x : Int32
  property y : Int32

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

xs = inputs.map(&.x)
ys = inputs.map(&.y)
x_lower_bound = xs.min
x_upper_bound = xs.max
y_lower_bound = ys.min
y_upper_bound = ys.max

safe_points = 0
threshold = 10000

(y_lower_bound..y_upper_bound).each do |y|
  (x_lower_bound..x_upper_bound).each do |x|
    total_dist = 0
    inputs.each { |p| total_dist += p.distance_to(Point.new(x, y)); break if total_dist > threshold }
    safe_points += 1 if total_dist < threshold
  end
end

puts safe_points
