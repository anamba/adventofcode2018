class Marble
  property value : Int32
  property cw : Marble
  property ccw : Marble

  def initialize(@value = 0, @cw = self, @ccw = self)
  end

  def insert_cw(val, offset = 1)
    ptr = self
    offset.times { ptr = ptr.cw }
    m = Marble.new(val, ptr.cw, ptr)
    ptr.cw.ccw = m
    ptr.cw = m
    m
  end

  def delete_ccw(offset = 7)
    ptr = self
    offset.times { ptr = ptr.ccw }
    ptr.ccw.cw = ptr.cw
    ptr.cw.ccw = ptr.ccw
    ptr
  end

  def print
    print "#{value} "
    ptr = self
    while (ptr = ptr.cw) && ptr.value > 0
      print "#{ptr.value} "
    end
    puts
  end
end

def run_game(pcount, mcount)
  scores = Hash(Int32, Int64).new

  root = Marble.new
  current = root
  current_player = 0
  # root.print

  # initialize scores
  (1..pcount).each { |p| scores[p] = 0 }

  (1..mcount).each do |m|
    current_player += 1
    current_player -= pcount if current_player > pcount

    if m % 23 == 0
      removed = current.delete_ccw(7)
      scores[current_player] += m
      scores[current_player] += removed.value
      current = removed.cw
    else
      current = current.insert_cw(m, 1)
    end
    # root.print
  end

  scores.values.max
end

while (str = gets)
  if str =~ /^(\d+) players; last marble is worth (\d+) points/ && (pcount = $1.to_i) && (mcount = $2.to_i)
    puts "Players: #{pcount}"
    puts "Marbles: #{mcount} (+1)"

    score = run_game(pcount, mcount)

    puts "High score: #{score}"
    puts
  else
    puts "Malformed input: #{str}"
    exit 1
  end
end
