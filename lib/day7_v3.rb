module Day7V3
  class << self
    def board(exp) ; "board['#{exp}']" end

    def expr(exp) ; /\d+/.match(exp) ? exp : board(exp) end

    def parse_assign(val, arrow, wire) 
      arrow == '->' && "#{board wire} = #{expr val}"
    end

    def parse_and(x, cmd, y, arrow, z) 
      cmd == "AND" && "#{board z} = #{expr x} & #{board y}" 
    end

    def parse_or(x, cmd, y, arrow, z) 
      cmd == "OR" && "#{board z} = #{board x} | #{board y}"
    end

    def parse_lshift(x, cmd, num, arrow, wire) 
      cmd == "LSHIFT" && "#{board wire} = #{board x} << #{num}" 
    end

    def parse_rshift(x, cmd, num, arrow, wire) 
      cmd == "RSHIFT" && "#{board wire} = #{board x} >> #{num}"
    end

    MAX = 2 ** 16
    def parse_not(cmd, x, arrow, wire)
      cmd == "NOT" && "#{board wire} = #{MAX} + ~#{board x} "
    end

    def parse(instruction)
      tokens = instruction.split
      [:parse_assign, :parse_and, :parse_or, :parse_rshift, :parse_lshift, :parse_not]
        .map    { |s| method(s) }
        .select { |m| m.parameters.length == tokens.length }
        .map    { |m| m.call(*tokens) }
        .find   { |cmd| cmd } 
    end

    def wire(instructions)
      cmds = instructions.map { |line| self.parse line }
      board = {}
      while !cmds.empty? 
        cmds = cmds.reject { |cmd| (eval(cmd) rescue nil).kind_of? Fixnum }
      end
      board
    end
  end
end
