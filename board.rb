require './pieces.rb'

class Board
  attr_accessor :grid

  def self.build_empty_board
    b = Board.new
    b.grid = []
    8.times { b.grid << ["."] * 8 }

    b
  end

  def build_board
    @grid = []
    8.times { @grid << ["."] * 8 }
    pieces = build_set_of_pieces

    pieces.each do |piece|
      self[piece.position] = piece
    end
  end

  def dup
    new_board = Board.build_empty_board

    @grid.each_with_index do |row, i|
      row.each_with_index do |space, j|
        if space.class != String
          position = space.position
          color    = space.color
          space.class.new(position, color, new_board)
        end
      end
    end

    new_board
  end

  def initialize
    self.build_board
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

  def build_set_of_pieces
    pieces = []

    # Build me some pawns
    8.times do |x|
      pieces << Pawn.new( [x, 1], :white, self )
      pieces << Pawn.new( [x, 6], :black, self )
    end

    # Build Rooks
    pieces << Rook.new( [0, 0], :white, self )
    pieces << Rook.new( [7, 0], :white, self )
    pieces << Rook.new( [0, 7], :black, self )
    pieces << Rook.new( [7, 7], :black, self )

    # Build Knights
    pieces << Knight.new( [1, 0], :white, self )
    pieces << Knight.new( [6, 0], :white, self )
    pieces << Knight.new( [1, 7], :black, self )
    pieces << Knight.new( [6, 7], :black, self )

    # Build Bishops
    pieces << Bishop.new( [2, 0], :white, self )
    pieces << Bishop.new( [5, 0], :white, self )
    pieces << Bishop.new( [2, 7], :black, self )
    pieces << Bishop.new( [5, 7], :black, self )

    # Build Queens
    pieces << Queen.new( [3, 0], :white, self )
    pieces << Queen.new( [3, 7], :black, self )

    # Build Kings
    pieces << King.new( [4, 0], :white, self )
    pieces << King.new( [4, 7], :black, self )

    pieces

  end

  def empty?(position)
    self[position] == "."
  end

  def move(pos, new_pos)
    piece = self[pos]

    if piece.is_a?(Piece) && piece.valid_move?(new_pos)
      piece.move(new_pos)

    elsif !piece.is_a?(Piece) || !piece.valid_move?(new_pos)
      puts "\nYou dumbfuck that wasn't a piece!\n" if !piece.is_a?(Piece)
      puts "\nThat wasn't a valid move!\n"     if  piece.is_a?(Piece)
    end
  end

  def move!(pos, new_pos)
  end

  def to_s
    #loops through board and calls piece.value, appends to string
    board_string = []

    @grid.reverse.each_with_index do |row, index|
      row = row.map do |piece|
        if piece != "."
          piece.value
        else
          piece
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

  def king_in_check?
    # Check -> When an opponents piece can capture the king
    # Checkmate -> if the king can't move from the check or use a piece
    # to block the check
    kings  = self.find_kings
    pieces = self.get_pieces

    kings.each do |king|
      pieces.each do |piece|
        next if piece == king
        return true if self.piece_checks_king?(king, piece)
      end
    end

    false
  end

  def piece_checks_king?(king, piece)
    piece.possible_positions.any { |position| position == king.position }
  end

  def get_pieces
    pieces = []

    @board.grid.each do |row|
      row.each do |item|
        pieces << item if item.is_a(Piece)
      end
    end

    pieces
  end

  def find_kings()
    kings = []
    @board.grid.each do |row|
      row.each do |piece|
        kings << piece if piece.class.name == "King"
      end
    end

    kings
  end

  def won?
    # TO FUCKING DO
    return false
  end
end