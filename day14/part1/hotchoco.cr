class Board
  property start : Recipe
  property count : Int32 = 0

  def initialize(@start)
  end
end

class Recipe
  property score : Int32
  property nxt : Recipe
  property prv : Recipe

  def initialize(@score, @nxt = self, @prv = self)
  end

  def insert_before(score)
    @prv = Recipe.new(score, self, @prv)
    prv.prv.nxt = prv
  end

  def insert_after(score)
    @nxt = Recipe.new(score, @nxt, self)
    nxt.nxt.prv = nxt
  end

  def advance(by steps : Int32)
    ptr = self
    steps.times { ptr = ptr.nxt }
    ptr
  end

  def return_next(count : Int32)
    list = Array(Int32).new
    ptr = self
    count.times { list << ptr.score; ptr = ptr.nxt }
    list.join
  end
end

def print_board(board, elves)
  ptr = board.start
  loop do
    if ptr == elves[0]
      print "(#{ptr.score})"
    elsif ptr == elves[1]
      print "[#{ptr.score}]"
    else
      print " #{ptr.score} "
    end

    ptr = ptr.nxt
    break if ptr == board.start
  end
  puts
end

def iterate(board, elves)
  # create new recipe and add to board (moving elves if new recipe is inserted prior to their current position)
  (elves[0].score + elves[1].score).to_s.split("").map(&.to_i).each { |r| board.start.insert_before(r); board.count += 1 }

  (0..1).each { |i| elves[i] = elves[i].advance(by: elves[i].score + 1) }

  # print_board(board, elves)
end

while (str = gets)
  if str =~ /^(\d+)/ && (count = $1.to_i?)
    board = Board.new(Recipe.new(3))
    board.start.insert_after(7)
    board.count = 2

    elves = [board.start, board.start.nxt]

    loop do
      iterate(board, elves)
      if count + 10 < board.count
        # print_board(board, elves)
        puts board.start.advance(by: count).return_next(10)
        break
      end
    end

    # exit
  end
end
