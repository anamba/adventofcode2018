alias Pos = NamedTuple(x: Int32, y: Int32)

class Node
  property value : String # in this case, a sequence of doors
  property! parent : Node
  property children = Array(Node).new
  property! pos : Pos? # is the END position after following all the doors in #value

  def initialize(@value = "", @children = Array(Node).new)
  end

  # copy everything but parent/children
  def initialize(from node : Node)
    @value = node.value
    @pos = node.pos
  end

  def new_child(val = "")
    child = Node.new(val)
    child.parent = self
    children << child
    child
  end

  def to_s(io, depth = 0)
    io << value << "\n"
    children.each do |child|
      io << "  " * depth << child.to_s(io, depth + 1)
    end
  end

  def path_length
    len = value.size
    children.each { |child| len += child.path_length }
    puts len
    len
  end
end

def parse_regex_into_tree(str : String) : Node
  root = Node.new
  node = root
  level = 0 # nesting level (tree depth)
  val = ""

  str.each_char do |c|
    case c
    when '^' # first child of root
      node = node.new_child
    when '(' # end current node, increase level, create child
      node.value, val = val, ""
      level += 1
      node = node.new_child
    when ')' # end current node, decrease level, create sibling
      node.value, val = val, ""
      level -= 1
      node = node.parent
      node = node.parent.new_child
    when '|' # end current node, create sibling
      node.value, val = val, ""
      node = node.parent.new_child
    when '$' # end final node
      node.value = val
    else
      val += c
    end
  end

  root
end

# cancel dupes that just take you through the same door twice
def react(input)
  reactive_pairs = ["NS", "SN", "EW", "WE"]

  loop do
    previous_size = input.size
    reactive_pairs.each { |str| input = input.gsub(str, "") }
    break if input.size == previous_size
  end

  input
end

def calculate_positions(root : Node, start = {x: 0, y: 0})
  # assume starting position is as provided
  x, y = start[:x], start[:y]

  # reduce the current value then walk it
  root.value = react(root.value)
  puts root.value
  root.value.each_char do |c|
    case c
    when 'N'
      y -= 1
    when 'S'
      y += 1
    when 'W'
      x -= 1
    when 'E'
      x += 1
    else
      raise "???"
    end
  end

  # puts "#{start[:x]},#{start[:y]} => #{x},#{y}"
  root.pos = {x: x, y: y}

  # walk tree and calculate positions for each node from there
  root.children.each { |child| calculate_positions(child, root.pos) }
end

# build up paths of single-char nodes and find the shortest path to each
def find_shortest_paths_by_pos(node : Node, path_to_here = Array(Node).new) : Hash(Pos, Array(Node))
  paths = Hash(Pos, Array(Node)).new

  # walk each position in our value
  path = path_to_here.dup
  x, y = node.pos[:x], node.pos[:y]
  new_node : Node

  node.value.each_char do |c|
    case c
    when 'N'
      y -= 1
    when 'S'
      y += 1
    when 'W'
      x -= 1
    when 'E'
      x += 1
    else
      raise "???"
    end
    new_node = Node.new(c.to_s)
    new_node.pos = {x: x, y: y}
    path = path.dup + [new_node]
    if (existing_path = paths[new_node.pos]) && existing_path.size <= path.size
      # leave it
    else
      paths[new_node.pos] = path
    end
  end
  # paths.each { |pos, path| puts "pre: #{pos[:x]}, #{pos[:y]}: #{path.map(&.value)}" }

  # # in our tree, siblings represent things to be combined, in all possible combinations (but in order)
  # child_paths = Array(Hash(Pos, Array(Node))).new
  # node.children.each do |child|
  #   puts "child #{child.value} starting path: #{child.pos[:x]}, #{child.pos[:y]}: #{path.map(&.value)}"

  #   # what we need is not to merge, but join together end to end
  #   # child_paths.merge!(find_shortest_paths_by_pos(child, path)) { |k, v1, v2| v1 + v2 }
  #   # child_paths.merge!(child_paths) { |k, v1, v2| [v1, v2].sort(&.size).first }
  # end

  # all_child_paths = Hash(Pos, Array(Node)).new
  # ptrs = Array(Int32).new(child_paths.size, 0)
  # done = false

  # while !done
  #   # select one value from each result and combine
  #   values = Array(String)
  #   child_paths.each { |hash|  }
  # end

  # in our tree, siblings represent things to be combined, in all possible combinations (but in order)
  # one iteration
  # done = false
  # while !done
  #   child 1 of child 1 of child 1
  #   done = true
  # end

  # # finally, merge all the child paths with what we have so far
  # paths.merge!(child_paths) { |k, v1, v2| [v1, v2].sort(&.size).first }
  # paths.each { |pos, path| puts "post: #{pos[:x]}, #{pos[:y]}: #{path.map(&.value)}" }

  paths
end

[
  "^WNE$",
  "^ENWWW(NEEE|SSE(EE|N))$",
  "^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$",
].each do |str|
  root = parse_regex_into_tree(str)
  puts "#{str} => #{root}"

  calculate_positions(root)
  # pp root

  # paths = find_shortest_paths_by_pos(root)
  # pp paths
  # paths.each { |pos, path| puts "#{pos[:x]}, #{pos[:y]}: #{path.map(&.value)}" }
  # longest_shortest_path = paths.values.sort_by(&.size).last
  # puts longest_shortest_path.map(&.value)
  # puts longest_shortest_path.size



  # giving up here (6:21pm)
  # i tried to see if i could re-use my regex tree instead of building up a complete 
  # decision tree, but i don't think that was the right way to go. building the whole
  # and running dijkstra again was probably the answer.
end
