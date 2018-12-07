class Step
  include Comparable(Step)

  property name : String
  property deps : Array(String)

  def initialize(@name, @deps = Array(String).new)
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

# pp steps

start = steps.values.select { |step| step.deps.empty? }.sort.first

current = start
completed = Array(String).new

loop do
  print current.name
  completed << current.name
  steps.delete(current.name)

  if (nextval = steps.values.select { |step| (step.deps - completed).empty? }.sort.first?)
    current = nextval
  else
    break
  end
end
puts
