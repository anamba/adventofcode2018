state : NamedTuple(start: Int32, plants: String) = {start: 0, plants: ""}
rules = Hash(String, String).new

while (str = gets)
  if str =~ /^initial state: ([#\.]+)$/
    state = {start: 0, plants: $1}
  elsif str =~ /^([#\.]{5}) => ([#\.])$/
    rules[$1] = $2
  elsif str.blank?
    # ok
  else
    puts "Malformed input: #{str}"
  end
end

def run_sim(state, rules, gen)
  start = state[:start] - 1
  new_plants = String.build { |s|
    plants = "...#{state[:plants]}..."
    # pp plants

    (plants.size - 4).times do |i|
      substr = plants[i, 5]
      s << (rules[substr]? || ".")
    end
  }

  if gen % 100 == 0 && new_plants =~ /^(\.+)(.*?)\.*$/
    start += $1.size
    new_plants = $2
  end

  {start: start, plants: new_plants}
end

# pp rules
# pp state

last_start = 0
last_gen = 1
last_total = 0
last_config = ""

(1..2000).each do |gen|
  new_state = run_sim(state, rules, gen)
  state = new_state

  if gen % 100 == 0
    puts "gen: #{last_gen} -> #{gen}"
    puts "start: #{last_start} -> #{state[:start]}"
    pp state

    i = state[:start]
    plants = state[:plants]
    total = 0
    plants.size.times do |j|
      total += i + j if plants[j] == '#'
    end

    puts "total: #{last_total} -> #{total}"

    if last_config == state[:plants]
      increment = (total - last_total) / (gen - last_gen)
      puts "Pattern stablized, calculating for 50 billion generations:"
      puts (50_000_000_000 - gen) * increment + total
      exit 0
    else
      last_gen, last_start = gen, state[:start]
      last_total = total
      last_config = state[:plants]
    end
  end
end

i = state[:start]
plants = state[:plants]
total = 0_i64
plants.size.times do |j|
  total += i + j if plants[j] == '#'
end

puts "total: #{total}"
