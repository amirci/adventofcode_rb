module Day7V4
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

  class << self
    def parse_assign(num, arrow, wire)
      arrow == "->" && -> board { board.assign(wire, num) }
    end

    def parse_bin(x, cmd, y, arrow, wire)
      op = {"AND" => :&, "OR" => :|, "LSHIFT" => :<<, "RSHIFT" => :>>}[cmd]
      op && -> (board) { board.assign(wire, x, y, &op) }
    end

    MAX = 2 ** 16

    def parse_not(cmd, x, arrow, wire)
      def complement(val) ; MAX + ~val end
      cmd == "NOT" && -> board { board.assign(wire, x) { |x| complement x }}
    end

    def parse(instruction)
      tokens = instruction.split
      [:parse_assign, :parse_bin, :parse_not]
        .map    { |s| method(s) }
        .select { |m| m.parameters.length == tokens.length }
        .map    { |m| m.call(*tokens) }
        .find   { |cmd| cmd } 
    end

    def wire(instructions)
      cmds = instructions.map { |line| parse line }
      board = Board.new
      while !cmds.empty? 
        cmds = cmds.select { |cmd| cmd.call(board).nil? }
      end
      board
    end
  end
end
