inputs = Array(Int32).new
while (str = gets)
  inputs << str.to_i32
end

pass = 1
acc = 0
done = false
history = Hash(Int32, Bool).new
while !done
  inputs.each do |i|
    history[acc] = true
    acc += i
    if history[acc]?
      puts "#{acc} reached twice"
      done = true
      break
    end
  end
  break if done

  pass += 1
  puts "No duplicate frequencies found yet (history size = #{history.keys.size}). Starting pass ##{pass}..."
end
