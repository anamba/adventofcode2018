class Cart
  property pos : NamedTuple(x: Int32, y: Int32)
  property dir : Char # ^ > v <
  property last_tick = 0
  getter next_action = :left

  def initialize(@pos, @dir)
  end

  def move(track)
    # figure out where we are: horizontal, vertical, corner or intersection
    case (seg = track[pos[:y]][pos[:x]])
    when '-'
      case dir
      when '>'
        @pos = {x: pos[:x] + 1, y: pos[:y]}
      when '<'
        @pos = {x: pos[:x] - 1, y: pos[:y]}
      else
        raise Exception.new("What happened??")
      end
    when '|'
      case dir
      when 'v'
        @pos = {x: pos[:x], y: pos[:y] + 1}
      when '^'
        @pos = {x: pos[:x], y: pos[:y] - 1}
      else
        raise Exception.new("What happened??")
      end
    when '\\' # corner, change direction then move
      case dir
      when '>'
        @pos = {x: pos[:x], y: pos[:y] + 1}
        @dir = 'v'
      when '^'
        @pos = {x: pos[:x] - 1, y: pos[:y]}
        @dir = '<'
      when '<'
        @pos = {x: pos[:x], y: pos[:y] - 1}
        @dir = '^'
      when 'v'
        @pos = {x: pos[:x] + 1, y: pos[:y]}
        @dir = '>'
      else
        raise Exception.new("What happened??")
      end
    when '/' # corner, change direction then move
      case dir
      when '<'
        @pos = {x: pos[:x], y: pos[:y] + 1}
        @dir = 'v'
      when '^'
        @pos = {x: pos[:x] + 1, y: pos[:y]}
        @dir = '>'
      when '>'
        @pos = {x: pos[:x], y: pos[:y] - 1}
        @dir = '^'
      when 'v'
        @pos = {x: pos[:x] - 1, y: pos[:y]}
        @dir = '<'
      else
        raise Exception.new("What happened??")
      end
    when '+' # if intersection, take an action
      case next_action
      when :left
        case dir
        when '>'
          @pos = {x: pos[:x], y: pos[:y] - 1}
          @dir = '^'
        when '<'
          @pos = {x: pos[:x], y: pos[:y] + 1}
          @dir = 'v'
        when 'v'
          @pos = {x: pos[:x] + 1, y: pos[:y]}
          @dir = '>'
        when '^'
          @pos = {x: pos[:x] - 1, y: pos[:y]}
          @dir = '<'
        else
          raise Exception.new("What happened??")
        end
      when :straight
        case dir
        when '>'
          @pos = {x: pos[:x] + 1, y: pos[:y]}
        when '<'
          @pos = {x: pos[:x] - 1, y: pos[:y]}
        when 'v'
          @pos = {x: pos[:x], y: pos[:y] + 1}
        when '^'
          @pos = {x: pos[:x], y: pos[:y] - 1}
        else
          raise Exception.new("What happened??")
        end
      when :right
        case dir
        when '>'
          @pos = {x: pos[:x], y: pos[:y] + 1}
          @dir = 'v'
        when '<'
          @pos = {x: pos[:x], y: pos[:y] - 1}
          @dir = '^'
        when 'v'
          @pos = {x: pos[:x] - 1, y: pos[:y]}
          @dir = '<'
        when '^'
          @pos = {x: pos[:x] + 1, y: pos[:y]}
          @dir = '>'
        else
          raise Exception.new("What happened??")
        end
      end

      @next_action = {
        :left     => :straight,
        :straight => :right,
        :right    => :left,
      }[@next_action]
    else
      puts "Reached unhandled track segment type #{seg}"
      exit 1
    end
  end

  def crashed?(carts)
    # puts "Looking for #{pos.inspect} in #{carts.map(&.pos).inspect}"
    carts.map(&.pos).includes?(pos)
  end
end

track = Array(String).new # designed to be immutable
carts = Array(Cart).new

lines = 0
while (str = gets)
  # carts can look like > < (replace with -) or ^ v (replace with |)
  if (index = (str =~ /([<>])/))
    carts << Cart.new({x: index, y: lines}, $1[0])
    str = str.gsub(/[<>]/, "-")
  elsif (index = (str =~ /([v^])/))
    carts << Cart.new({x: index, y: lines}, $1[0])
    str = str.gsub(/[v^]/, "|")
  end
  track << str
  lines += 1
end

pp carts

def print_track(track, carts)
  track.each_with_index do |line, index|
    carts.select { |c| c.pos[:y] == index }.each do |cart|
      x = cart.pos[:x]
      line = "#{line[0...x]}#{cart.dir}#{line[x + 1..-1]}"
    end
    puts line
  end
end

tick = 0
loop do
  tick += 1

  # print_track(track, carts)

  # reorder carts by current position, then move each in order
  carts = carts.sort { |a, b| {a.pos[:x], a.pos[:y]} <=> {b.pos[:x], b.pos[:y]} }
  while (cart = carts.select { |c| c.last_tick < tick }.first?)
    cart.move(track)
    cart.last_tick = tick

    if cart.crashed?(carts - [cart])
      puts
      puts "!!! Carts crashed at #{cart.pos} during tick #{tick}"
      puts "Removing carts with pos #{cart.pos}"
      carts.reject! { |c| c.pos == cart.pos }
    end
  end

  puts "#{carts.size} cart(s) remain"

  if carts.size <= 1
    puts carts.first.pos
    exit
  end

  puts "Tick #{tick} finished"
  # break if 16 < tick
end
