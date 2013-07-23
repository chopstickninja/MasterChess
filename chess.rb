class ChessGame
end

class Player
end

class Board
  def build_board
    @grid = []
    8.times.do { @grid << [] }
  end

  def build_set_of_pieces
    pieces = Hash.new { |hash, key| hash[key] = []}

    # Build me some white pawns
    8.times do |x|
      pieces[white] << Pawn.new([x,1], "white", @board)
    end

    #


  end

  def initialize
    self.build_board
  end

  # Setter
  def []=(x, y)
    @grid[x][y]
  end

  #Getter
  def [](x, y)
    @grid[x][y]
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
  def possible_positions
    x, y = @position
    new_positions = []

    self.steps.each do |direction|
        until self.out_of_bounds?(x, y)
          i, j  = direction
          x, y  = x + i, y + j
          new_positions << [x, y] unless self.out_of_bounds?(x, y)
        end

        # DUH! We need to reset back to the original spot!
        x, y = @position
    end

    new_positions
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



#knight = Knight.new([3,3])
#king = King.new([5,4])

#p knight.possible_positions
#p king.possible_positions

r = Rook.new([3,4])
b = Bishop.new([3,4])
q = Queen.new([3,4])
kg = King.new([3,4])

#p r.possible_positions
#p b.possible_positions
#p q.possible_positions
#p s.rook_positions
#p s.bishop_positions

p kg.possible_positions