require "./spec_helper"

describe Asm do
  it "works" do
    # vm = Asm::VM.new([2, 3, 2, 1])
    # vm.addr(2, 3, 2)
    # vm.registers[2].should eq 3

    # vm = Asm::VM.new([2, 3, 2, 1])
    # vm.addi(2, 3, 2)
    # vm.registers[2].should eq 5

    # vm = Asm::VM.new([3, 2, 1, 1])
    # vm.addi(2, 1, 2)
    # vm.registers[2].should eq 2

    # vm = Asm::VM.new([2, 3, 2, 1])
    # vm.mulr(2, 3, 2)
    # vm.registers[2].should eq 2

    # vm = Asm::VM.new([2, 3, 2, 1])
    # vm.muli(2, 3, 2)
    # vm.registers[2].should eq 6
  end
end
