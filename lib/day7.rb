module Day7
  class << self
    def parse_assign(num, arrow, wire)
      return nil unless arrow == "->"
      return -> (board) { board[wire] = num.to_i } if /\d+/.match num
      -> (board) { board[num] && board[wire] = board[num] }
    end

    # x AND y -> z
    # 1 AND y -> z
    # x OR  y -> z
    def parse_bin(x, cmd, y, arrow, z)
      return nil unless cmd == "AND" || cmd == "OR"
      return -> (board) { board[y] && board[z] = 1 & board[y] } if x == "1" && cmd == "AND"
      return -> (board) { board[x] && board[y] && board[z] = board[x] & board[y] } if cmd == "AND"
      -> (board) { board[x] && board[y] && board[z] = board[x] | board[y] }
    end

    def parse_shift(x, shift, num, arrow, wire)
      return nil unless shift == "LSHIFT" || shift == "RSHIFT"
      return ->(board) { board[x] && board[wire] = board[x] << num.to_i } if shift == "LSHIFT" 
      ->(board) { board[wire] = board[x] && board[x] >> num.to_i }
    end

    MAX = 2 ** 16

    def complement(val) ; MAX + ~val end

    def parse_not(cmd, x, arrow, wire)
      return nil unless cmd == "NOT"
      -> (board) { board[x] && board[wire] = (complement board[x]) }
    end

    def parse(instruction)
      tokens = instruction.split
      [:parse_assign, :parse_bin, :parse_shift, :parse_not]
        .map    { |s| method(s) }
        .select { |m| m.parameters.length == tokens.length }
        .map    { |m| m.call(*tokens) }
        .find   { |cmd| cmd } 
    end

    def wire(instructions)
      cmds = instructions.map { |line| parse line }
      board = {}
      while !cmds.empty? 
        cmds = cmds.select { |cmd| cmd.call(board).nil? }
      end
      board
    end
  end
end
