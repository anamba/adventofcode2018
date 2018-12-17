enum TileType
  Spring
  Clay
  Water
  Flow
end

class Tile
  property x : Int32
  property y : Int32
  property type : TileType

  def_equals(@x, @y, @type)

  def initialize(@x, @y, @type)
  end

  def pos : Position
    {@x, @y}
  end

  def to_s
    "(#{@x}, #{@y}, #{type.to_s})"
  end

  def move_to(tile : Tile)
    @x, @y = tile.x, tile.y
    self
  end

  def move_up
    @y -= 1
    self
  end

  def move_down
    @y += 1
    self
  end

  def move_left
    @x -= 1
    self
  end

  def move_right
    @x += 1
    self
  end
end

alias Position = Tuple(Int32, Int32)
alias Bounds = NamedTuple(min_x: Int32, min_y: Int32, max_x: Int32, max_y: Int32)

class State
  getter spring = Tile.new(500, 0, TileType::Spring)
  getter flows = Array(Tile).new
  getter tiles = Hash(Position, Tile).new

  getter min_x : Int32 = 0
  getter max_x : Int32 = 0
  getter min_y : Int32 = 0
  getter max_y : Int32 = 0

  def initialize
    File.open(ARGV[0]? || "sampleinput") do |f|
      while (str = f.gets)
        if str =~ /^(x|y)=(\d+),\s(x|y)=(\d+)\.\.(\d+)$/
          if $1 == "x" && $3 == "y"
            # puts "x: #{$2}, y: #{$4}..#{$5}"
            x = $2.to_i
            ($4.to_i..$5.to_i).each { |y| add_tile(Tile.new(x, y, TileType::Clay)) }
          elsif $1 == "y" && $3 == "x"
            # puts "x: #{$4}..#{$5}, y: #{2}"
            y = $2.to_i
            ($4.to_i..$5.to_i).each { |x| add_tile(Tile.new(x, y, TileType::Clay)) }
          else
            raise "Malformed input: #{str}"
          end
        else
          raise "Malformed input: #{str}"
        end
      end
    end

    # x should be one wider on each side to account for possible overflows
    @max_x = tiles.values.map(&.x).tap { |xs| @min_x = xs.min - 1 }.max + 1
    @max_y = tiles.values.map(&.y).tap { |ys| @min_y = ys.min }.max

    add_tile(spring)
    add_flow(spring.x, spring.y + 1)
  end

  def print(limit : Int32 = max_y)
    ([min_y, 0].min..[max_y, limit].min).each do |y|
      ((min_x)..(max_x)).each do |x|
        c : Char = '.'

        if (t = tile_at?(x, y))
          if t == spring
            c = '+'
          elsif t.type.clay?
            c = '#'
          elsif t.type.water?
            c = '~'
          elsif t.type.flow?
            c = '|'
          end
        end

        print c
      end
      puts
    end

    puts "Total flows: #{@tiles.values.select { |t| t.type.flow? }.reject { |t| t.y < min_y || max_y < t.y }.size}"
    puts "Total waters: #{@tiles.values.select { |t| t.type.water? }.size}"
    puts "Total flows+waters: #{@tiles.values.select { |t| t.type.water? || t.type.flow? }.reject { |t| t.y < min_y || max_y < t.y }.size}"
  end

  def add_tile(tile : Tile) : Tile
    @tiles[tile.pos] = tile
  end

  def add_flow(x, y) : Tile
    tile = Tile.new(x, y, TileType::Flow)
    @flows << tile unless @flows.includes?(tile)
    add_tile(tile)
  end

  def tile_at?(x, y)
    @tiles[{x, y}]?
  end

  def tile_at?(tile : Tile)
    tile_at?(tile.x, tile.y)
  end

  def tile_below?(tile : Tile)
    tile_at?(tile.x, tile.y + 1)
  end

  def move_to_end_of_flow(tile : Tile)
    if (tile_at?(tile.x, tile.y))
      while (below = tile_below?(tile)) && below.type.flow?
        tile.move_down
      end
    end
  end

  def spread_horizontally(tile : Tile)
    y = tile.y

    left_wall = nil
    right_wall = false
    has_bottom = true
    contained_x_values = Array(Int32).new

    # if contained on the left
    x = tile.x
    while (min_x <= x)
      if (t = tile_at?(x, y)) && (t.type.clay? || t.type.water?)
        left_wall = x
        break
      else
        # check for bottom
        if (t = tile_at?(x, y + 1))
          case t.type
          when .clay?, .water?
            # ok
          else
            has_bottom = false
            break
          end
        else
          has_bottom = false
          break
        end

        contained_x_values << x
        x -= 1
      end
    end

    # ... and contained on the right
    x = tile.x + 1
    while (x <= max_x)
      if (t = tile_at?(x, y)) && (t.type.clay? || t.type.water?)
        right_wall = x
        break
      else
        # check for bottom
        if (t = tile_at?(x, y + 1))
          case t.type
          when .clay?, .water?
            # ok
          else
            has_bottom = false
            break
          end
        else
          has_bottom = false
          break
        end

        contained_x_values << x
        x += 1
      end
    end

    contained_x_values.sort!

    if left_wall.is_a?(Int32) && right_wall.is_a?(Int32) && has_bottom
      return false if contained_x_values.empty?

      # puts "Nicely contained"
      if (t = tile_at?(tile))
        t.type = TileType::Water
      end
      (left_wall + 1..right_wall - 1).each do |x|
        if (t = tile_at?(x, y))
          t.type = TileType::Water
        else
          add_tile(Tile.new(x, y, TileType::Water))
        end
      end
      return true
    elsif left_wall.is_a?(Int32)
      if contained_x_values.any?
        # puts "Adding flow from #{contained_x_values.last + 1},#{y}, left wall at #{left_wall}"
        contained_x_values.each { |x| add_tile(Tile.new(x, y, TileType::Flow)) }
        add_flow(contained_x_values.last + 1, y)
        return false # original flow has to stop for now
      end
    elsif right_wall.is_a?(Int32)
      if contained_x_values.any?
        # puts "Flow from #{contained_x_values.first - 1},#{y}, right wall at #{right_wall}"
        contained_x_values.each { |x| add_tile(Tile.new(x, y, TileType::Flow)) }
        add_flow(contained_x_values.first - 1, y)
        return false # original flow has to stop for now
      end
    else
      if contained_x_values.any?
        # puts "Bidirectional flow on #{y}"
        contained_x_values.each { |x| add_tile(Tile.new(x, y, TileType::Flow)) }
        add_flow(contained_x_values.first - 1, y)
        add_flow(contained_x_values.last + 1, y)
        return false # original flow has to stop for now
      end
    end

    false
  end

  # find next place water can reach
  def iterate
    passes = 0

    # pp flows
    flows.each do |source|
      if !source.type.flow?
        # puts "Source was covered, removing from flows..."
        flows.delete(source)
        return true
      end
      new_tile = Tile.new(source.x, source.y, TileType::Flow)
      move_to_end_of_flow(new_tile)

      if (cur = tile_at?(new_tile))
        # puts "cur: #{cur.to_s}"
        if (below = tile_below?(cur))
          case below.type
          when .water?
            # puts "Water"
            # see if that water can spread out further
            if spread_horizontally(new_tile)
              return true
            else
              # puts "trace up"
              # trace back up flow to next pool
              new_tile.move_up
              if spread_horizontally(new_tile)
                # new_tile.type = TileType::Water
                # add_tile(new_tile)
                return true
              else
                # puts "Cannot spread here #{new_tile.to_s}"
                passes += 1
                return false if flows.size <= passes
                next
              end
            end
          when .clay?
            # puts "Clay"
            # try spreading from here
            if spread_horizontally(cur)
              return true
            else
              # puts "Cannot spread here #{new_tile.to_s}"
              passes += 1
              return false if flows.size <= passes
              next
            end
          end
        else
          if new_tile.move_down.y <= max_y
            # puts "Add a new tile #{new_tile.to_s}"
            add_tile(new_tile)
            return true
          end
        end
      else
        # starting point
        add_tile(new_tile)
        return true
      end

      # could not find a place for new tile
      puts "Finished one flow (for now?)"
      passes += 1
      return false if flows.size <= passes
      next
    end

    puts "Finished all flows"
    false
  end
end

state = State.new
# state.print

round = 0

while state.iterate
  round += 1

  if round % 100 == 0
    puts "\nFinished round #{round}"
    # state.print
  end

  # break if 5000 < round
end

state.print

# correct answer, part 1: 32552
# correct answer, part 2: 26405
