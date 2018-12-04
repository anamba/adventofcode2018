inputs = Array(String).new
while (str = gets)
  inputs << str
end

def has_exactly_n_of_any_letter(input : String, n : Int)
  letters = input.split("").sort
  return false unless letters.size >= n # sanity check

  current = letters.shift
  count = 1
  ptr : String?

  loop do
    if (ptr = letters[0]?)
      if ptr == current # same letter
        count += 1
      else # not same letter, end of sequence
        # if that sequence was what we're looking for, we're done
        return true if count == n

        # otherwise, start over
        count = 1
      end

      current = letters.shift
    else
      return count == n
    end
  end
end

# puts inputs.inspect
# puts inputs.map { |s| has_exactly_n_of_any_letter(s, 1) }
# puts inputs.map { |s| has_exactly_n_of_any_letter(s, 2) }
# puts inputs.map { |s| has_exactly_n_of_any_letter(s, 3) }

twos = inputs.select { |s| has_exactly_n_of_any_letter(s, 2) }.size
threes = inputs.select { |s| has_exactly_n_of_any_letter(s, 3) }.size
puts twos * threes
