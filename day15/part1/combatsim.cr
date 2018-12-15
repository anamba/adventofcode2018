struct Square
  property x : Int32
  property y : Int32

  def initialize(@x, @y)
  end

  def pos
    {x, y}
  end

  def_equals(@x, @y)

  def adjacent_open_squares(board : Array(String), pieces : Array(Piece), path_so_far : Array(Square)) : Array(Square)
    invalid_positions = pieces.reject(&.dead).map(&.pos) + path_so_far.map(&.pos)

    ret = Array(Square).new
    [{x, y-1}, {x-1, y}, {x+1, y}, {x, y+1}].each do |(col, row)|
      if board[row]?.try &.[col]? == '.' && !invalid_positions.includes?({col, row})
        ret << Square.new(col, row)
      end
    end
    ret
  end

  def adjacent_to?(square : Square)
    [{x, y-1}, {x-1, y}, {x+1, y}, {x, y+1}].each do |spos|
      return true if spos == square.pos
    end
    false
  end

  def shortest_path_to(squares : Array(Square), board : Array(String), pieces : Array(Piece)) : Array(Square)?
    squares.each do |square|
      if square.x == x && square.y == y
        return Array(Square).new
      end
      if adjacent_to?(square)
        return [square] # we're done!
      end
    end

    # begin breadth first search

    # create and seed
    paths_to_check = Deque(Tuple(Square, Array(Square))).new
    squares.each do |square|
      adjacent_open_squares(board, pieces, [square]).each { |s| paths_to_check << {square, [s]} }
    end

    max_path_size = 0

    while paths_to_check.any?
      square, path = paths_to_check.shift

      if path.size > max_path_size
        max_path_size = path.size
        puts "Checking paths of size #{max_path_size}, #{paths_to_check.size} more paths to check"
      end
      # break if path.size > board.size * 3 # circuit-breaker
      # pp path

      if path.last.adjacent_to?(square)
        puts "shortest path from #{x},#{y} to #{square.x},#{square.y}: #{path.size+1}"
        return path + [square] # we're done!
      end

      path.last.adjacent_open_squares(board, pieces, path + [square]).each { |s| paths_to_check << {square, path + [s]} }
    end

    # puts "Giving up"
    return nil
  end
end

class Piece
  property ptype : Char # 'E' or 'G'
  property x : Int32
  property y : Int32
  property ap : Int32 = 3
  property hp : Int32 = 200
  property dead : Bool = false

  def initialize(@ptype, @x, @y)
  end

  def elf?
    ptype == 'E'
  end

  def goblin?
    ptype == 'G'
  end

  def pos
    {x, y}
  end

  def enemies(pieces : Array(Piece))
    elf? ? pieces.reject(&.dead).select(&.goblin?) : pieces.reject(&.dead).select(&.elf?)
  end

  def adjacent_enemy(pieces : Array(Piece)) : Piece?
    candidates = Array(Piece).new
    living_enemies = enemies(pieces)
    [{x, y-1}, {x-1, y}, {x+1, y}, {x, y+1}].each do |spos|
      if (enemy = living_enemies.select { |p| p.pos == spos }.first?)
        candidates << enemy
      end
    end
    if candidates.any?
      min_hp = candidates.map(&.hp).min
      candidates.select { |c| c.hp == min_hp }.first
    end
  end

  def attack(piece : Piece)
    piece.hp -= ap
    if piece.hp <= 0
      piece.dead = true
    end
    piece
  end

  def adjacent_open_squares(board : Array(String), pieces : Array(Piece)) : Array(Square)
    ret = Array(Square).new
    [{x, y-1}, {x-1, y}, {x+1, y}, {x, y+1}].each do |(col, row)|
      if board[row]?.try &.[col]? == '.' && !pieces.reject(&.dead).map(&.pos).includes?({col, row})
        ret << Square.new(col, row)
      end
    end
    ret
  end

  def move_toward_closest_reachable_target(board : Array(String), pieces : Array(Piece))
    pp enemies(pieces).map(&.adjacent_open_squares(board, pieces))
    targets = enemies(pieces).map(&.adjacent_open_squares(board, pieces)).flatten
    if (shortest_path = Square.new(x, y).shortest_path_to(targets, board, pieces)) && (nextpos = shortest_path.first?)
      puts "Distance to target (#{shortest_path.last.x},#{shortest_path.last.y}): #{shortest_path.size}. Moving from #{x},#{y} to #{nextpos.x},#{nextpos.y}"
      @x, @y = nextpos.x, nextpos.y
    end
  end
end

board = Array(String).new
pieces = Array(Piece).new

while (str = gets)
  if str =~ /^#+$/
    board << str
  elsif str =~ /^#(.*)#$/
    board << String.build do |s|
      str.chars.each_with_index do |c, index|
        case c
        when '#', '.'
          s << c
        when 'E', 'G'
          s << '.'
          pieces << Piece.new(c, index, board.size)
        else
          puts "Malformed input: invalid char #{c} in #{str}"
          exit 1
        end
      end
    end
  elsif str =~ /Outcome/
    # puts str
  elsif str.blank?
    # ok
  else
    puts "Malformed input: #{str}"
    exit 1
  end
end

def print_board(board, pieces)
  board.each_with_index do |row, rownum|
    if (rowpieces = pieces.select { |p| p.y == rownum }).any?
      row.chars.each_with_index do |c, colnum|
        if (colpieces = pieces.select { |p| !p.dead && p.x == colnum && p.y == rownum }).any?
          print colpieces.first.ptype
        else
          print c
        end
      end
      puts
    else
      puts row
    end
  end
end

def iterate_board(board, pieces)
  pieces.reject(&.dead).sort_by { |a| {a.y, a.x} }.each do |piece|
    next if piece.dead # could have died mid-round

    if piece.enemies(pieces).empty?
      return false
    end

    # move toward closest target if possible + necessary, then attack if possible
    if (enemy = piece.adjacent_enemy(pieces))
      piece.attack(enemy)
    else
      piece.move_toward_closest_reachable_target(board, pieces)
      if (enemy = piece.adjacent_enemy(pieces))
        piece.attack(enemy)
      end
    end
  end

  # otherwise continue
  true
end

print_board(board, pieces)

rounds = 0

while iterate_board(board, pieces)
  rounds += 1
  puts "\nRound #{rounds} completed:"
  print_board(board, pieces)
  # break if 2 < rounds
end

print_board(board, pieces)

puts "Combat ends after #{rounds} full rounds"
winner = Hash{'E' => "Elves", 'G' => "Goblins"}[pieces.reject(&.dead).map(&.ptype).uniq.first]
total_hp = pieces.reject(&.dead).map(&.hp).sum
puts "#{winner} win with #{total_hp} total hit points left"
puts "Outcome: #{rounds} * #{total_hp} = #{rounds * total_hp}"
