claims = Hash(Int32, NamedTuple(start: NamedTuple(x: Int32, y: Int32), width: Int32, height: Int32)).new
while (str = gets)
  if str =~ /^#(\d+)\s+@\s+(\d+),(\d+):\s+(\d+)x(\d+)$/ &&
     (id = $1.to_i?) && (startx = $2.to_i?) && (starty = $3.to_i?) &&
     (width = $4.to_i?) && (height = $5.to_i?)
    claims[id] = {start: {x: startx, y: starty}, width: width, height: height}
  else
    puts "Malformed input: #{str}"
  end
end

claimed_squares = Hash(Tuple(Int32, Int32), Array(Int32)).new

claims.each do |id, claim|
  claim[:height].times do |row|
    claim[:width].times do |col|
      square = {claim[:start][:x] + col, claim[:start][:y] + row}
      if claimed_squares[square]?
        claimed_squares[square] << id
      else
        claimed_squares[square] = [id]
      end
    end
  end
end

conflict_statuses = Hash(Int32, Bool).new
claims.each { |k, v| conflict_statuses[k] = false }

claimed_squares.values.each do |claim_ids|
  if claim_ids.size > 1
    claim_ids.each { |id| conflict_statuses[id] = true }
  end
end

conflict_statuses.each do |id, has_conflicts|
  if !has_conflicts
    puts "Claim ##{id} has no conflicts!"
  end
end
