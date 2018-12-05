exit unless input = gets

puts input

class String
  def without_letter(letter)
    gsub(/#{letter}/i, "")
  end
end

REACTIVE_PAIRS = ("A".."Z").to_a.map { |c| [c + c.downcase, c.downcase + c] }.flatten

def react(input)
  loop do
    previous_size = input.size
    REACTIVE_PAIRS.each { |str| input = input.gsub(str, "") }
    break if input.size == previous_size
  end
  # puts input
  puts input.size

  input.size
end

best_size = Int32::MAX
best_letter = "A"

("A".."Z").to_a.each do |letter|
  puts letter
  size = react(input.without_letter(letter))
  if size < best_size
    best_size = size
    best_letter = letter
  end
end

puts "Best: #{best_letter} = #{best_size}"
