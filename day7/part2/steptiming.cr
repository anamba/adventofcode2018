class Step
  include Comparable(Step)

  property name : String
  property deps : Array(String)
  property timereq : Int32

  def initialize(@name, @deps = Array(String).new)
    @timereq = @name[0].ord - 65 + 1 + 60
  end

  def <=>(b)
    name <=> b.name
  end
end

steps = Hash(String, Step).new
while (str = gets)
  if str =~ /^Step (\w+) must be finished before step (\w+) can begin.$/
    dep = $1
    name = $2

    if (step = steps[dep]?)
      # already there, good
    else
      steps[dep] = Step.new(dep)
    end

    if (step = steps[name]?)
      step.deps << dep
    else
      steps[name] = Step.new(name, [dep])
    end
  else
    puts "Malformed input: #{str}"
    exit 1
  end
end

pp steps

in_progress = Array(Step).new
completed = Array(String).new

time = 0
WorkerCount = 5

loop do
  # first load up workers
  available_workers = WorkerCount - in_progress.size
  if available_workers > 0
    # check to see if there are jobs we can do
    steps.values.select { |step| (step.deps - completed).empty? }.sort.first(available_workers).each do |step|
      puts "Starting #{step.name} at #{time}"
      in_progress << steps.delete(step.name).not_nil!
    end
  end

  # then run one tick
  time += 1
  in_progress.each do |step|
    step.timereq -= 1
    if step.timereq == 0
      puts "Finished #{step.name} at #{time}"
      completed << step.name
    end
  end
  in_progress.reject! { |step| step.timereq == 0 }

  break if steps.empty? && in_progress.empty?
end

puts time
