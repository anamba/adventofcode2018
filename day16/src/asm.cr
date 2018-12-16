require "./opcodes"

module Asm
  VERSION = "0.1.0"

  alias Registers = Tuple(Int32, Int32, Int32, Int32) # reg A B C D
  alias Instruction = Tuple(Int8, Int32, Int32, Int8) # opcode valA valB register
  alias Example = NamedTuple(before: Registers, instruction: Instruction, after: Registers)

  class VM
    property registers : Array(Int32)

    def initialize(@registers = Array(Int32).new(4, 0_i32))
    end

    # {#% for reg, idx in %w(a b c d) %}
    #   def {#{reg.id}} ; @registers[{#{idx}}] ; end
    #   def {#{reg.id}}=(val) ; @registers[{#{idx}}] = val ; end
    # {#% end %}
  end

  examples = Array(Example).new
  program = Array(Instruction).new

  File.open(ARGV[0]? || "sampleinput") do |f|
    while (str = f.gets)
      if str =~ /^Before:\s+\[(\d+),\s*(\d+),\s*(\d+),\s*(\d+)\]$/
        before : Registers = {$1.to_i, $2.to_i, $3.to_i, $4.to_i}

        if (str = f.gets) && str =~ /^(\d+)\s+(\d+)\s+(\d+)\s+(\d+)$/
          inst : Instruction = {$1.to_i8, $2.to_i, $3.to_i, $4.to_i8}

          if (str = f.gets) && str =~ /^After:\s+\[(\d+),\s*(\d+),\s*(\d+),\s*(\d+)\]$/
            after : Registers = {$1.to_i, $2.to_i, $3.to_i, $4.to_i}
            examples << {before: before, instruction: inst, after: after}
          else
            raise "Malformed register values: #{str}"
          end
        else
          raise "Malformed instruction: #{str}"
        end
      elsif str.blank?
        # ok

      elsif str =~ /^(\d+)\s+(\d+)\s+(\d+)\s+(\d+)$/
        inst = {$1.to_i8, $2.to_i, $3.to_i, $4.to_i8}
        program << inst
      end
    end
  end

  # pp examples
  # pp program

  opcode_map = Hash(Int8, String).new
  candidates = Hash(Int8, Array(String)).new
  anticandidates = Hash(Int8, Array(String)).new

  examples.each do |example|
    # try each opcode to see whether the result could match the after
    {% for op in VM::Ops %}
      vm = VM.new(example[:before].to_a)
      inst = example[:instruction]
      vm.{{op.id}}(inst[1], inst[2], inst[3])
      if vm.registers == example[:after].to_a && !(anticandidates[inst[0]]?.try &.includes?({{op}}))
        # puts "#{inst[0]} could be {{op.id}}"
        candidates[inst[0]] = Array(String).new unless candidates.has_key?(inst[0])
        candidates[inst[0]] << {{op}} unless candidates[inst[0]].includes?({{op}})
      else
        # puts "#{inst[0]} could NOT be {{op.id}}"
        anticandidates[inst[0]] = Array(String).new unless anticandidates.has_key?(inst[0])
        anticandidates[inst[0]] << {{op}} unless anticandidates[inst[0]].includes?({{op}})
        if candidates[inst[0]]?.try &.includes?({{op}})
          candidates[inst[0]].delete({{op}})
        end
      end
    {% end %}

    # puts "#{candidates.size} candidate(s) found"
  end

  runs = 0
  while (unsolved = candidates.values.select { |v| v.size > 0 }).any?
    runs += 1
    # puts "Run #{runs}:"
    # candidates.each { |k, v| puts "#{k}: #{v.size}" }
    # puts
    # anticandidates.each { |k, v| puts "#{k}: #{v.size}" }

    # add any new solved opcodes to map and add to anticandidates for all others
    if (solved = candidates.reject { |k, _v| opcode_map.has_key?(k) }.select { |_k, v| v.size == 1 }).any?
      solved.each do |k, v|
        op = v.first
        opcode_map[k] = op
        candidates.each { |k, v| v.delete(op) }
        anticandidates.each { |_k, v| v << op unless v.includes?(op) }
      end
    end

    # pp opcode_map

    # break if 20 < runs
  end

  pp opcode_map

  # run the program
  vm = VM.new
  program.each do |inst|
    vm.op opcode_map[inst[0]], inst[1], inst[2], inst[3]
  end
  pp vm.registers
end
