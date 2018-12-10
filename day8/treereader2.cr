class Node
  property child_count : Int32 = 0
  property metadata_count : Int32 = 0
  property children = Array(Node).new
  property metadata = Array(Int32).new

  def initialize(@child_count, @metadata_count)
  end

  def value : Int32
    return metadata.sum if child_count == 0

    values = metadata.map do |m|
      next unless children[m - 1]?
      children[m - 1].value.as(Int32)
    end.compact

    values.size > 0 ? values.sum : 0
  end
end

inputs = gets.to_s.split(/\s/).map(&.to_i32)
# pp inputs

root = Node.new(inputs.shift, inputs.shift)

def read_node_contents(node, input_stream)
  node.child_count.times do |index|
    new_node = Node.new(input_stream.shift, input_stream.shift)
    node.children << new_node
    read_node_contents(new_node, input_stream)
  end
  node.metadata_count.times do |index|
    node.metadata << input_stream.shift
  end
end

read_node_contents(root, inputs)

puts root.value
