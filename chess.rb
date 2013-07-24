require 'colorize'


class ChessGame

  def self.new_game
  end

  def initialize(player1, player2)
    @board = Board.new
  end

  def play

    until won?
    end

  end

  def won?
    return true if self.find_kings.length < 2
    self.king_in_check?
  end

  def king_in_check?
    kings = self.find_kings
    pieces = self.get_pieces

    kings.each do |king|
      pieces.each do |piece|
        next if piece == king
        return true if in_check?(king, piece)
      end
    end

    false
  end

  def in_check?(king, piece)
    king.possible_positions.any { |item| piece.possible_moves.include?(item) }
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
end


class Player
  def initialize(name)
    @name = name
  end

  def move
    # TODO
  end
end


class Board
  attr_accessor :grid

  def build_board
    @grid = []
    8.times { @grid << ["."] * 8 }
    pieces = build_set_of_pieces

    pieces.each do |piece|
      x, y = piece.position
      self[x, y] = piece
    end
  end

  def initialize
    self.build_board
  end

  # Setter - board[x, y] = obj
  def []=(x, y, obj)
    @grid[y][x] = obj
  end

  #Getter
  def [](x, y)
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

  def empty?(x, y)
    self[x, y] == "."
  end
end


class Piece
  attr_accessor :position, :color

  def initialize(position, color, board)
    @position = position
    @color    = color
    @board    = board
  end

  def move(new_position)
    possible_positions = self.possible_positions
    raise PositionError unless valid_move?(new_position)
    @position = new_position
  end

  def valid_move?(new_position)
    self.possible_positions.include?(new_position)
  end

  def value
    if self.class.name == "Knight"
      val = "N"
    else
      val = self.class.name[0]
    end
    val.colorize(@color)
  end

  def to_s
    "#{self.class.name}"
  end

  def out_of_bounds?(x, y)
    (x > 7 || x < 0 ) || (y > 7 || y < 0)
  end
end


class Stepper < Piece
  def possible_positions
    # TODO -> just pass around positions array not x y
    new_positions = []

    self.steps.each do |move|
      i, j = move
      x, y = @position
      x, y = x + i, y + j

      if self.legal_move?(x, y)
        new_positions << [x, y]
      end
    end

    new_positions
  end


  def legal_move?(x, y)
    other = @board[x, y]
    return false if self.out_of_bounds?(x, y)
    return false if !@board.empty?(x, y) && self.color == other.color

    true
  end

end


class Slider < Piece
  def move(new_position)
    x, y = new_position
  end

  def possible_positions
    x, y = @position
    possible_positions = []

    self.steps.each do |direction|
        until self.out_of_bounds?(x, y) #|| this space is occupied by same color
          i, j  = direction
          x, y  = x + i, y + j

          if @board.empty?(x, y) || @board[x, y].color != self.color
            possible_positions << [x, y] unless self.out_of_bounds?(x, y)
          end

          break if !@board.empty?(x, y)
        end

        # DUH! We need to reset back to the original spot!
        x, y = @position
    end

    possible_positions
  end
end


class King < Stepper
  def steps
    [[0, 1], [0, -1], [1, 0], [-1, 0], [-1, -1], [-1, 1], [1, -1], [1, 1]]
  end
end


class Knight < Stepper
  def steps
    [[1, 2], [-2, 1], [2, 1],[-1, 2], [-2, -1], [-1, -2], [1, -2], [2, -1]]
  end
end


class Bishop < Slider
  def steps
    [[1, 1], [-1, 1], [1, -1], [-1, -1]]
  end
end


class Queen < Slider
  def steps
    [[1, 0], [0, 1], [-1, 0], [0, -1], [1, 1], [-1, 1], [1, -1], [-1, -1]]
  end
end


class Rook < Slider
    def steps
    [[1, 0], [0, 1], [-1, 0], [0, -1]]
  end
end


class Pawn < Piece
end


board = Board.new
p board[1, 0].possible_positions