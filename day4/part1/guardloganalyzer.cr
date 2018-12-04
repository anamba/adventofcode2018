inputs = Array(String).new
while (str = gets)
  inputs << str
end

inputs.sort!

alias Sleep = NamedTuple(guard: Int32, start_min: Int32, end_min: Int32, duration: Int32) # NOTE: start_min is >=, end_min is <
sleeps = Array(Sleep).new
log_entries = Array(NamedTuple(time: Time, guard: Int32, event: String)).new

guard : Int32 = 0
current_sleep = Hash(Symbol, Int32).new
inputs.each do |line|
  if line =~ /^\[(\d{4})\-(\d{2})\-(\d{2}) (\d{2})\:(\d{2})\] Guard \#(\d+) begins shift$/ &&
     (y = $1.to_i?) && (m = $2.to_i?) && (d = $3.to_i?) && (hour = $4.to_i?) && (min = $5.to_i?) && (id = $6.to_i?)
    t = Time.new(y,m,d, hour,min)
    guard = id
    log_entries << {time: t, guard: guard, event: "begins shift"}
    current_sleep[:guard] = guard
  elsif line =~ /^\[(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})\] falls asleep$/ &&
    (y = $1.to_i?) && (m = $2.to_i?) && (d = $3.to_i?) && (hour = $4.to_i?) && (min = $5.to_i?)
    t = Time.new(y,m,d, hour,min)
    log_entries << {time: t, guard: guard, event: "falls asleep"}
    current_sleep[:start_min] = min
  elsif line =~ /^\[(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})\] wakes up$/ &&
    (y = $1.to_i?) && (m = $2.to_i?) && (d = $3.to_i?) && (hour = $4.to_i?) && (min = $5.to_i?)
    t = Time.new(y,m,d, hour,min)
    log_entries << {time: t, guard: guard, event: "wakes up"}
    current_sleep[:end_min] = min
    current_sleep[:duration] = current_sleep[:end_min] - current_sleep[:start_min]
    sleeps << Sleep.from(current_sleep)
  else
    puts "Malformed input: #{line}"
  end
end

# pp sleeps

sleeps_by_guard = Hash(Int32, Array(Sleep)).new
sleeps.each do |s|
  if sleeps_by_guard[s[:guard]]?
    sleeps_by_guard[s[:guard]] << s
  else
    sleeps_by_guard[s[:guard]] = [s]
  end
end

top_sleeper = sleeps_by_guard.values.sort_by(&.map(&.[:duration]).sum).last
top_sleeper_id = top_sleeper.first[:guard]

minutes = Hash(Int32, Int32).new(default_value: 0)

top_sleeper.each do |sleep|
  (sleep[:start_min]...sleep[:end_min]).each { |min| minutes[min] = minutes[min] + 1 }
end

top_sleeper_top_minute = minutes.invert[minutes.values.max]

puts "Top sleeper: Guard ##{top_sleeper_id}"
puts "Minute top sleeper most often found asleep: #{top_sleeper_top_minute}"
