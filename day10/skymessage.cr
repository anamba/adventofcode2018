alias Position = NamedTuple(x: Int32, y: Int32)

class Drone
  property pos : Position
  property velo : NamedTuple(dx: Int32, dy: Int32)

  def initialize(@pos, @velo)
  end

  def move
    @pos = {x: pos[:x] + velo[:dx], y: pos[:y] + velo[:dy]}
  end

  def revert
    @pos = {x: pos[:x] - velo[:dx], y: pos[:y] - velo[:dy]}
  end
end

drones = Array(Drone).new

while (str = gets)
  if str =~ /^position=<\s*(\-?\d+),\s+(\-?\d+)>\s+velocity=<\s*(\-?\d+),\s+(\-?\d+)>$/
    drones << Drone.new({x: $1.to_i, y: $2.to_i}, {dx: $3.to_i, dy: $4.to_i})
  else
    puts "Malformed input: #{str}"
  end
end

# pp drones

seconds = 0
times_contracted = 0
times_expanded = 0
minx, miny, maxx, maxy = 0, 0, 0, 0
done = false

loop do
  positions = drones.map(&.pos)
  xs = positions.map(&.[:x])
  ys = positions.map(&.[:y])
  newminx, newmaxx = xs.min, xs.max
  newminy, newmaxy = ys.min, ys.max

  if (newmaxx - newminx) < (maxx - minx) || (newmaxy - newminy) < (maxy - miny)
    # puts "contracted"
    times_contracted += 1
  else
    # puts "expanded"
    times_expanded += 1
  end

  minx, maxx, miny, maxy = newminx, newmaxx, newminy, newmaxy

  puts "second #{seconds}: x: #{minx} - #{maxx}, y: #{miny} - #{maxy}"

  if done
    poshash = Hash(Position, Drone).new
    drones.each { |d| poshash[d.pos] = d }

    (miny..maxy).each do |y|
      (minx..maxx).each do |x|
        print poshash[Position.new(x: x, y: y)]? ? "#" : "."
      end
      puts
    end

    break
  end

  if 2 <= times_expanded
    drones.each { |d| d.revert }
    seconds -= 1
    done = true
  else
    drones.each { |d| d.move }
    seconds += 1
  end
end
