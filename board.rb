require './pieces.rb'

class Board
  attr_accessor :grid

  def initialize(position_hash=Board.blank_board)
    self.build_board(position_hash)
  end

  # Setter - board[x, y] = obj
  def []=(pos, obj)
    x, y = pos
    @grid[y][x] = obj
  end

  #Getter
  def [](pos)
    x, y = pos
    @grid[y][x]
  end

  def self.blank_board
    blank = {}
    # use each for Pawns
    #

    8.times { |num| blank[[1,num]] = {:item => Pawn, :color => :white }}
    8.times { |num| blank[[6,num]] = {:item => Pawn, :color => :black }}

    home_row = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]

    home_row.each_with_index do |piece, index|
      blank[[0, index]] = {:item => piece, :color => :white}
      blank[[7, index]] = {:item => piece, :color => :black}
    end

     blank
  end

  def self.build_empty_board
    b = Board.new
    b.grid = []
    8.times { b.grid << [nil] * 8 }

    b
  end

  def self.out_of_bounds?(pos)
    x, y = pos
    (x > 7 || x < 0 ) || (y > 7 || y < 0)
  end

  def build_board(positions_hash)
    @grid = []
    8.times { @grid << [nil] * 8 }

    positions_hash.each do |position, piece_hash|
      x, y = position

      color = piece_hash[:color]
      piece = piece_hash[:item].new([y,x], color,self)

      @grid[x][y] = piece
    end
  end

  def dup
    new_board = Board.build_empty_board

    @grid.each_with_index do |row, i|
      row.each_with_index do |space, j|
        if !space.nil?
          position = space.position
          color    = space.color
          space.class.new(position, color, new_board)
        end
      end
    end

    new_board
  end

  def empty?(position)
    self[position].nil?
  end

  def find_king(color)
    self.get_pieces(color).each do |piece|
      return piece if piece.class == King
    end

    nil
  end

  def get_pieces(color)
    pieces = []
    @grid.each do |row|
      row.each do |piece|
        pieces << piece unless piece.nil?
      end
    end

    pieces.select{|piece| piece.color == color}
  end

  def in_check?(color)
    #look at all opponent's pieces and call valid moves on each. if any of these
    #valid moves contains own king's position, return true.

    opponent_color = (color == :white ? :black : :white)
    opponent_pieces = self.get_pieces(opponent_color)
    possible_positions = []

    king = self.find_king(color)
    return false if king.nil?

    opponent_pieces.each do |opponent_piece|
      possible_positions += opponent_piece.possible_positions
    end

    possible_positions.any? {|position| position == king.position}
  end

  def move(pos, new_pos)
    #dup.move, then check in_check? ? don't allow, re-prompt : self.move
    piece = self[pos]

    if valid_move?(pos, new_pos)
      piece.move(new_pos)
    else
      puts "\nYou dumbfuck that wasn't a piece!\n" if piece.nil?
      puts "\nThat wasn't a valid move!\n"     if  !piece.nil?
    end
  end

  def to_s
    board_string = []

    @grid.reverse.each_with_index do |row, index|
      row = row.map do |piece|
        if piece.nil?
          "."
        else
          piece.value
        end
      end

      char_index = (8 - index).to_s
      row.unshift(char_index)
      row << char_index
      board_string << row.join(" ")
    end

    letters = ("a".."h").to_a
    letters.unshift(" ")
    board_string.unshift(letters.join(" "))
    board_string.push(letters.join(" "))
    board_string.join("\n")
  end

  def won?
    # TODO
    return false
  end

  def valid_move?(pos, new_pos)
    test_board = self.dup
    test_piece = test_board[pos]
    return false if test_piece.nil?
    return false unless test_piece.valid_move?(new_pos)

    test_piece.move(new_pos)
    return false if test_board.in_check?(test_piece.color)

    true
  end
end