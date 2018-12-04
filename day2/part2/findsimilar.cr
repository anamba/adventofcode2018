inputs = Array(String).new
while (str = gets)
  inputs << str
end

inputs.map { |s| s.split("") }.each_combination(2, true) do |(letters1, letters2)|
  if (letters1 - letters2).size <= 1
    differences = 0
    letters1.each_with_index { |l, i| differences += 1 unless l == letters2[i]? }
    if differences <= 1
      puts letters1.join("")
      puts letters2.join("")
    end
  end
end
