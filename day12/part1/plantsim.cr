states = Array(NamedTuple(start: Int32, plants: String)).new
rules = Hash(String, String).new

while (str = gets)
  if str =~ /^initial state: ([#\.]+)$/
    states << {start: 0, plants: $1}
  elsif str =~ /^([#\.]{5}) => ([#\.])$/
    rules[$1] = $2
  elsif str.blank?
    # ok
  else
    puts "Malformed input: #{str}"
  end
end

def run_sim(state, rules)
  start = state[:start] - 1
  new_plants = String.build { |s|
    plants = "...#{state[:plants]}..."
    # pp plants

    (plants.size - 4).times do |i|
      substr = plants[i, 5]
      s << (rules[substr]? || ".")
    end
  }

  if new_plants =~ /^(\.+)(.*?)\.*$/
    start += $1.size
    new_plants = $2
  end

  count = new_plants.split("").select { |c| c == "#" }.size

  {start: start, plants: new_plants}
end

pp rules
pp states.first
20.times do
  state = run_sim(states.last, rules)
  pp state
  states << state
end

i = states.last[:start]
plants = states.last[:plants]
total = 0
plants.size.times do |j|
  total += i + j if plants[j] == '#'
end

puts total
