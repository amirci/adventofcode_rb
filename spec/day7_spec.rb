require "day7"
require "day7_v2"
require "day7_v3"
require "day7_v4"
require 'rantly/rspec_extensions' 

describe "wire" do
  describe "sample circuit board" do
    let(:circuits) {
      """
      123 -> x
      456 -> y
      x AND y -> d
      x OR y -> e
      x LSHIFT 2 -> f
      y RSHIFT 2 -> g
      NOT x -> h
      NOT y -> i
      """.split("\n").map(&:strip).reject(&:empty?)
    }

    let(:board) { Day7::wire circuits }
    let(:expected) {
      pairs = {d: 72, e: 507, f: 492, g: 114, h: 65412, i: 65079, x: 123, y: 456}.map { |k, v| [k.to_s, v] }
      Hash[pairs]
    }

    it "sets the board to the expected values" do
      expect(board).to eq expected
    end
  end
end

class Rantly
  def wire ; sized(20) { string(:lower)[0..1] } end
  def wire_val ; range(1, 10000) end
  def assignCmd
    num = integer
    w = wire
    ["#{num} -> #{w}", num, w]
  end

  def andCmd
    x = wire
    y = x.succ
    xval, yval = array(2) { wire_val }
    z = wire
    ["#{x} AND #{y} -> #{z}", x, xval, y, yval, z]
  end
end

describe "Day7 parse" do
  context "an AND command" do
    it "Creates a class that does and AND between values" do
      property_of { andCmd }.check do |str, x, xval, y, yval, z|
        board = {x => xval, y => yval}
        cmd = Day7::parse(str)
        cmd.call board
        expect(board[z]).to eq(xval & yval), "#{str} >>> #{board}"
      end
    end
  end

  context "Assign cmd" do
    it "Creates a cmd that sets the wire to the value" do
      property_of { assignCmd }.check do |str, num, w|
        board = {}
        Day7::parse(str).call board
        expect(board[w]).to eq num
      end
    end
  end
end

describe "loading the input file" do

  let(:instructions) do
    IO.readlines File.dirname(__FILE__) + "/day7.input.txt"
  end

  context "Using V1" do
    let(:board) { Day7::wire instructions }

    it "returns the value for wire a" do
      expect(board['a']).to eq 46065
    end
  end

  context "Using V2" do
    let(:board) { Day7V2::wire instructions }

    it "parses an OR cmd" do
      cmd = Day7V2::parse "cj OR cp -> cq"
      expect(!!cmd).to be true
      expect(cmd).to be_kind_of Day7V2::OrCmd
    end

    it "returns the value for wire a" do
      expect(board['a']).to eq 46065
    end
  end

  context "Using V3" do
    let(:board) { Day7V3::wire instructions }

    it "returns the value for wire a" do
      expect(board['a']).to eq 46065
    end
  end

  context "Using V4" do
    let(:board) { Day7V4::wire instructions }

    it "returns the value for wire a" do
      expect(board['a']).to eq 46065
    end
  end

end
