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

  pp examples
  # pp program

  threes = 0
  examples.each do |example|
    candidates = Array(String).new

    # try each opcode to see whether the result could match the after
    {% for op in %w(addr addi mulr muli banr bani borr bori setr seti gtir gtri gtrr eqir eqri eqrr) %}
      vm = VM.new(example[:before].to_a)
      inst = example[:instruction]
      vm.{{op.id}}(inst[1], inst[2], inst[3])
      if vm.registers == example[:after].to_a
        puts "Could be {{op.id}}"
        candidates << {{op}}
      end
    {% end %}

    puts "#{candidates.size} candidate(s) found"
    if 3 <= candidates.size
      threes += 1
    end
  end

  puts threes
end
