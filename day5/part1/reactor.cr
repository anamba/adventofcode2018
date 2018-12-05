exit unless input = gets
input = input.not_nil!

puts input

reactive_pairs = ("A".."Z").to_a.map { |c| [c + c.downcase, c.downcase + c] }.flatten
# pp reactive_pairs

loop do
  previous_size = input.size
  reactive_pairs.each { |str| input = input.gsub(str, "") }
  break if input.size == previous_size
end

puts input
puts input.size
