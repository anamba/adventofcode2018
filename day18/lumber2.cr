enum AcreType
  Open
  Wooded
  Lumberyard
end

struct Acre
  property x : Int32
  property y : Int32
  property type : AcreType

  def initialize(@x, @y, c)
    @type = case c
            when '.' then AcreType::Open
            when '|' then AcreType::Wooded
            when '#' then AcreType::Lumberyard
            else
              raise "Invalid acre type"
            end
  end

  def to_char : Char
    case type
    when AcreType::Open       then '.'
    when AcreType::Wooded     then '|'
    when AcreType::Lumberyard then '#'
    else
      raise "Invalid acre type"
    end
  end

  def to_s(io)
    io << to_char
  end
end

class State
  property acres = Array(Array(Acre)).new

  getter min_x : Int32 = 0
  getter max_x : Int32 = 0
  getter min_y : Int32 = 0
  getter max_y : Int32 = 0

  def initialize
    File.open(ARGV[0]? || "sampleinput") do |f|
      while (str = f.gets)
        if str =~ /^[\.\|\#]+$/
          row = Array(Acre).new
          str.each_char_with_index { |c, index| row << Acre.new(index, @max_y, c) }
          @acres << row
          @max_y += 1
        else
          raise "Malformed input: #{str}"
        end
      end

      @max_y = @acres.size - 1
      @max_x = @acres.last.size - 1
    end
  end

  # blank but with same number of rows for convenience
  def initialize(from state : State)
    state.acres.each do |row|
      @acres << Array(Acre).new
    end
    @min_x = state.min_x
    @max_x = state.max_x
    @min_y = state.min_y
    @max_y = state.max_y
  end

  def to_s(io)
    acres.each do |row|
      row.each &.to_s(io)
      io << "\n"
    end
  end

  def next_state
    new_state = self.class.new(from: self)

    acres.each_with_index do |row, index|
      row.each do |acre|
        new_state.acres[index] << next_state(acre)
      end
    end

    new_state
  end

  def next_state(acre : Acre)
    # structs are passed by value so acre is already a copy, which we can modify and return

    case acre.type
    when AcreType::Open
      # An open acre will become filled with trees if three or more adjacent acres contained trees.
      # Otherwise, nothing happens.
      if acre_has_adjacent?(acre, AcreType::Wooded, 3)
        acre.type = AcreType::Wooded
      end
    when AcreType::Wooded
      # An acre filled with trees will become a lumberyard if three or more adjacent acres were lumberyards.
      # Otherwise, nothing happens.
      if acre_has_adjacent?(acre, AcreType::Lumberyard, 3)
        acre.type = AcreType::Lumberyard
      end
    when AcreType::Lumberyard
      # An acre containing a lumberyard will remain a lumberyard if it was adjacent to at least one other lumberyard and at least one acre containing trees.
      if acre_has_adjacent?(acre, AcreType::Lumberyard, 1) && acre_has_adjacent?(acre, AcreType::Wooded, 1)
        # nothing
      else
        # Otherwise, it becomes open.
        acre.type = AcreType::Open
      end
    else
      raise "Unexpected acre type"
    end

    acre
  end

  def acre_has_adjacent?(acre : Acre, type : AcreType, number : Int32)
    number <= acres_adjacent_to(acre).select { |a| a.type == type }.size
  end

  def acres_adjacent_to(acre : Acre) : Array(Acre)
    ret = Array(Acre).new
    ((acre.y - 1)..(acre.y + 1)).each do |y|
      next if y < min_y || max_y < y
      # puts y
      ((acre.x - 1)..(acre.x + 1)).each do |x|
        next if x < min_x || max_x < x
        next if x == acre.x && y == acre.y
        ret << acres[y][x]
      end
    end
    # puts "#{acre.x},#{acre.y}: #{ret}"

    ret
  end

  def count(type : AcreType)
    count = 0
    acres.each { |row| count += row.select { |a| a.type == type }.size }
    count
  end
end

state = State.new
minute = 0

puts state

data = Array(Int32).new

loop do
  state = state.next_state
  minute += 1

  if minute == 1000
    puts "Starting capture"
  elsif minute == 2000
    puts "Finished capture, finding longest pattern"

    (10..100).each do |i|
      if (sequences = data.in_groups_of(i).first(5).uniq).size == 1
        puts "Pattern of length #{i} found: #{sequences.first.inspect}"
        val = sequences.first[(1000000000 - 1000) % i]
        puts "Final value should be: #{val}"
      end
    end
    exit
  end

  if 1000 <= minute < 2000
    # puts "\nAfter #{minute} minute(s):"
    # puts state

    wooded_count = state.count(AcreType::Wooded)
    lumberyard_count = state.count(AcreType::Lumberyard)

    # puts "Wooded: #{wooded_count}"
    # puts "Lumberyards: #{lumberyard_count}"
    # puts "Resource value: #{wooded_count * lumberyard_count}"

    data << wooded_count * lumberyard_count
  end
end

puts "Done"
