
module Day7V2

  class Board
    attr_reader :wires

    def initialize ; @wires = {} end

    def [](y) ; @wires[y] end

    def assign(wire, *exprs)
      values = exprs.map { |exp| value exp }
      return nil if values.any?(&:nil?) 
      @wires[wire] = block_given? ? yield(*values) : values[0]
    end

    private 
    def value(exp)
      /\d+/.match(exp) ? exp.to_i : @wires[exp]
    end
  end

  class AssignCmd 
    def initialize(wire, val) ; @wire, @val = [wire, val] end
    def wireIt(board) ; board.assign(@wire, @val) end
    def self.parse(val, arrow, wire) ; arrow == '->' && AssignCmd.new(wire, val) end
  end

  class AndCmd
    def initialize(lhs, rhs, wire) ; @lhs, @rhs, @wire = [lhs, rhs, wire] end
    def wireIt(board) ; board.assign(@wire, @lhs, @rhs) { |l, r| l & r } end
    def self.parse(x, cmd, y, arrow, z) ; cmd == "AND" && AndCmd.new(x, y, z) end
  end
  
  class OrCmd
    def initialize(lhs, rhs, wire) ; @lhs, @rhs, @wire = [lhs, rhs, wire] end
    def wireIt(board) 
      board.assign(@wire, @lhs, @rhs) { |l, r| l | r }
    end
    def self.parse(x, cmd, y, arrow, z) ; cmd == "OR" && OrCmd.new(x, y, z) end
  end

  class LeftShiftCmd 
    def initialize(lhs, num, wire) ; @lhs, @num, @wire = [lhs, num, wire] end
    def wireIt(board) 
      board.assign(@wire, @lhs) { |lhs| lhs << @num }
    end
    def self.parse(x, cmd, num, arrow, wire) ; cmd == "LSHIFT" && LeftShiftCmd.new(x, num.to_i, wire) end
  end

  class RightShiftCmd 
    def initialize(lhs, num, wire) ; @lhs, @num, @wire = [lhs, num, wire] end
    def wireIt(board) 
      board.assign(@wire, @lhs) { |lhs| lhs >> @num }
    end
    def self.parse(x, cmd, num, arrow, wire) ; cmd == "RSHIFT" && RightShiftCmd.new(x, num.to_i, wire) end
  end

  class NotCmd 
    MAX = 2 ** 16
    def initialize(lhs, wire) ; @lhs, @wire = [lhs, wire] end
    def wireIt(board) 
      board.assign(@wire, @lhs) { |v| NotCmd.complement(v) }
    end
    def self.complement(val) ; MAX + ~val end
    def self.parse(cmd, x, arrow, wire)
      cmd == "NOT" && NotCmd.new(x, wire)
    end
  end

  def self.parse(instruction)
    tokens = instruction.split
    [AssignCmd, AndCmd, OrCmd, RightShiftCmd, LeftShiftCmd, NotCmd]
      .map    { |k| k.method(:parse) }
      .select { |m| m.parameters.length == tokens.length }
      .map    { |m| m.call(*tokens) }
      .find   { |cmd| cmd } 
  end

  def self.wire(instructions)
    cmds = instructions.map do |line| 
      self.parse line
    end

    board = Board.new
    len = cmds.length + 1
    while !cmds.empty? && cmds.length < len
      len = cmds.length
      cmds = cmds.reject { |cmd| cmd.wireIt board }
    end
    board
  end

end
