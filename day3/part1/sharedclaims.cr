inputs = Array(NamedTuple(id: Int32, start: NamedTuple(x: Int32, y: Int32), width: Int32, height: Int32)).new
while (str = gets)
  if str =~ /^#(\d+)\s+@\s+(\d+),(\d+):\s+(\d+)x(\d+)$/ &&
     (id = $1.to_i?) && (startx = $2.to_i?) && (starty = $3.to_i?) &&
     (width = $4.to_i?) && (height = $5.to_i?)
    inputs << {id: id, start: {x: startx, y: starty}, width: width, height: height}
  else
    puts "Malformed input: #{str}"
  end
end

# puts inputs

claimed_squares = Hash(Tuple(Int32, Int32), Array(Int32)).new

inputs.each do |claim|
  claim[:height].times do |row|
    claim[:width].times do |col|
      square = {claim[:start][:x] + col, claim[:start][:y] + row}
      if claimed_squares[square]?
        claimed_squares[square] << claim[:id]
      else
        claimed_squares[square] = [claim[:id]]
      end
    end
  end
end

puts claimed_squares.values.map { |claim_ids| claim_ids.size > 1 ? 1 : 0 }.sum
