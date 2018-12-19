require "./opcodes"

module Asm
  VERSION = "0.1.0"

  alias Instruction = Tuple(String, Int32, Int32, Int8) # op valA valB register

  class VM
    property registers : Array(Int32)
    property ip_reg : Int8  # instruction pointer register, 0 - 5
    property ip : Int32 = 0 # instruction pointer

    def initialize(@registers = Array(Int32).new(6, 0_i32), @ip_reg = 0_i8)
    end

    # {#% for reg, idx in %w(a b c d) %}
    #   def {#{reg.id}} ; @registers[{#{idx}}] ; end
    #   def {#{reg.id}}=(val) ; @registers[{#{idx}}] = val ; end
    # {#% end %}

    Ops = %w(addr addi mulr muli banr bani borr bori setr seti gtir gtri gtrr eqir eqri eqrr)

    def op(inst : Asm::Instruction)
      code, a, b, c = inst

      if code == "ip"
        ip(a)
      end

      {% for op in Ops %}
        if code == {{op}}
          registers[@ip_reg] = @ip
          {{op.id}}(a, b, c)
          @ip = registers[@ip_reg]
          @ip += 1
        end
      {% end %}

      # puts @ip
    end
  end

  program = Array(Instruction).new

  File.open(ARGV[0]? || "sampleinput") do |f|
    while (str = f.gets)
      if str =~ /^\#ip\s(\d+)$/
        inst = {"ip", $1.to_i, 0, 0_i8}
        program << inst
      elsif str =~ /^(\w+)\s+(\d+)\s+(\d+)\s+(\d+)/
        inst = {$1, $2.to_i, $3.to_i, $4.to_i8}
        program << inst
      end
    end
  end

  pp program

  # run the program
  vm = VM.new # part 1
  # vm.registers[0] = 1 # part 2
  trace = Deque(Int32).new

  # assume first line is #ip X
  ip_inst = program.shift
  vm.op(ip_inst)

  i : Int64 = 0_i64

  loop do
    i += 1

    # trace << vm.ip

    # if i % 1_000_000 == 0
    #   puts "\ni = #{i} - #{vm.ip}: #{vm.registers.inspect}"
    # end

    if inst = program[vm.ip]?
      # pp inst
      vm.op(inst)
    else
      break
    end

    # if 100 < trace.size
    #   puts "abort"
    #   break
    # end
  end
end

pp vm.registers
