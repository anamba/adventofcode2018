class Node
  property child_count : Int32 = 0
  property metadata_count : Int32 = 0
  property children = Array(Node).new
  property metadata = Array(Int32).new

  def initialize(@child_count, @metadata_count)
  end
end

inputs = gets.to_s.split(/\s/).map(&.to_i32)
# pp inputs

root = Node.new(inputs.shift, inputs.shift)
all_nodes = [root]

def read_node_contents(node, input_stream, all_nodes)
  node.child_count.times do |index|
    new_node = Node.new(input_stream.shift, input_stream.shift)
    all_nodes << new_node
    read_node_contents(new_node, input_stream, all_nodes)
  end
  node.metadata_count.times do |index|
    node.metadata << input_stream.shift
  end
end

read_node_contents(root, inputs, all_nodes)

puts all_nodes.map { |n| n.metadata.sum }.sum
