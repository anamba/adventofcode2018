class Cell
  property grid : Grid
  property x : Int32
  property y : Int32
  property power_level : Int32

  def initialize(@grid, @x, @y)
    @power_level = calculate_power_level
  end

  def rack_id
    x + 10
  end

  def calculate_power_level
    # Begin with a power level of the rack ID times the Y coordinate.
    val = rack_id * y

    # Increase the power level by the value of the grid serial number (your puzzle input).
    val += grid.serial_number

    # Set the power level to itself multiplied by the rack ID.
    val *= rack_id

    # Keep only the hundreds digit of the power level (so 12345 becomes 3; numbers with no hundreds digit become 0).
    val = val % 1000 / 100

    # Subtract 5 from the power level.
    val -= 5

    val
  end
end

class Grid
  property serial_number : Int32
  property cells = Array(Array(Cell)).new

  def initialize(@serial_number)
    300.times do |y|
      cells << Array(Cell).new
      300.times do |x|
        cells[y] << new_cell(x + 1, y + 1)
      end
    end
  end

  def new_cell(x, y)
    cell = Cell.new(self, x, y)
  end

  def cell_at(x, y)
    cell = cells[y - 1][x - 1]
    # sanity check
    # raise Exception.new("Failed sanity check at #{x}, #{y}") if cell.x != x || cell.y != y
    cell
  end

  def power_of_square_at(startx, starty, size)
    power = 0
    ((starty)...(starty + size)).each do |y|
      ((startx)...(startx + size)).each do |x|
        power += cell_at(x, y).power_level
      end
    end
    power
  end

  def find_max_power_square
    max_power = 0
    max_power_x = 0
    max_power_y = 0
    max_power_size = 0
    (1..300).each do |size|
      (1..(300 - size)).each do |y|
        (1..(300 - size)).each do |x|
          if max_power < (power = power_of_square_at(x, y, size))
            puts "#{x},#{y},#{size} = #{power}"
            max_power = power
            max_power_x, max_power_y, max_power_size = x, y, size
          end
        end
      end
    end
    puts "MAX: #{max_power_x},#{max_power_y},#{max_power_size} = #{max_power}"
  end
end

# grid = Grid.new(57)
# puts grid.cell_at(122, 79).power_level == -5

# grid = Grid.new(39)
# puts grid.cell_at(217, 196).power_level == 0

# grid = Grid.new(71)
# puts grid.cell_at(101, 153).power_level == 4

# grid = Grid.new(18)
# puts grid.power_of_square_at(33, 45, 3) == 29
# grid.find_max_power_square

# grid = Grid.new(42)
# puts grid.power_of_square_at(21, 61, 3) == 30
# grid.find_max_power_square

grid = Grid.new(7347)
grid.find_max_power_square
