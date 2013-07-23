require 'colorize'


class ChessGame
end


class Player
end


class Board
  attr_accessor :grid

  def build_board
    @grid = []
    8.times { @grid << [" "] * 8 }

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
      pieces << Pawn.new( [x, 1], :white, @grid )
      pieces << Pawn.new( [x, 6], :white, @grid )
    end

    # Build Rooks
    pieces << Rook.new( [0, 0], :white, @grid )
    pieces << Rook.new( [7, 0], :white, @grid )
    pieces << Rook.new( [0, 7], :black, @grid )
    pieces << Rook.new( [7, 7], :black, @grid )

    # Build Knights
    pieces << Knight.new( [1, 0], :white, @grid)
    pieces << Knight.new( [6, 0], :white, @grid)
    pieces << Knight.new( [1, 7], :black, @grid)
    pieces << Knight.new( [6, 7], :black, @grid)

    # Build Bishops
    pieces << Bishop.new( [2, 0], :white, @grid)
    pieces << Bishop.new( [5, 0], :white, @grid)
    pieces << Bishop.new( [2, 7], :black, @grid)
    pieces << Bishop.new( [5, 7], :black, @grid)

    # Build Queens
    pieces << Queen.new( [3, 0], :white, @grid)
    pieces << Queen.new( [3, 7], :black, @grid)

    # Build Kings
    pieces << King.new( [4, 0], :white, @grid)
    pieces << King.new( [4, 7], :black, @grid)

    pieces

  end

  def to_s
    #loops through board and calls piece.value, appends to string
    board_string = []

    @grid.each_with_index do |row, index|
      row = row.map do |piece|
        if piece != " "
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
    self[x, y] == " "
  end
end


class Piece
  attr_accessor :position

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
    return "N" if self.class.name == "Knight"
    self.class.name[0]
  end

  def out_of_bounds?(x, y)
    (x > 7 || x < 0 ) || (y > 7 || y < 0)
  end

end

class Stepper < Piece
  def possible_positions
    new_positions = []

    self.steps.each do |move|
      i, j = move
      x, y = @position
      new_positions << [x + i, y + j]
    end
    new_positions.select {|x, y| !self.out_of_bounds?(x, y)}
  end
end


class Slider < Piece

  def filter_possible_positions
    filtered = []

    self.possible_positions.each do |position|
      x, y = position


    end

  end

  def move(new_position)
    x, y = new_position
  end

  def possible_positions
    x, y = @position
    possible_positions = []

    self.steps.each do |direction|
        until self.out_of_bounds?(x, y)
          i, j  = direction
          x, y  = x + i, y + j
          possible_positions << [x, y] unless self.out_of_bounds?(x, y)
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
p board