class ChessGame
end

class Player
end

class Board
  # 8 x 8
end


class Piece
  attr_accessor :position

  def initialize(position)
    @position = position
  end

  def move(new_position)
    possible_positions = self.possible_positions
    raise PositionError unless possible_positions.include?(new_position)
    @position = new_position
  end

  def valid_move?(new_position)
    self.possible_positions.include?(new_position)
  end
end

class Stepper < Piece

  def initialize(position, steps)
    super(position)
    @steps = steps
  end

  def possible_positions
    new_positions = []

    @steps.each do |move|
      i, j = move
      x, y = @position
      new_positions << [x + i, y + j]
    end
    new_positions.select {|x, y| (x >= 0 && x < 8) && (y >= 0 && y < 8)}
  end
end


class Slider < Piece
  #CANNOT LEAP OVER PIECES
  def initialize(position, piece)
    super(position)
    #@steps = self.get_directions(piece_direction)
  end

  def get_directions(piece)
    steps = []

    if piece == "rook"
      steps += self.rook_positions
    elsif piece == "bishop"
      # TODO
    end
      # TODO
  end

  def rook_positions
    step_array = [[1, 0], [0, 1], [-1, 0], [0, -1]
    self.calculate_positions(step_array)
  end

  def bishop_positions
  end

  def calculate_positions(step_array)
    x, y = @position
    new_positions = []

    step_array.each do |direction|
        until self.out_of_bounds?(x, y)
          i, j  = direction
          x, y  = x + i, y + j
          new_positions << [[x, y]] unless self.out_of_bounds?(x, y)
        end

        # DUH! We need to reset back to the original spot!
        x, y = @position
    end

    new_positions
  end
  end

  def out_of_bounds?(x, y)
    (x > 7 || x < 0 ) || (y > 7 || y < 0)
  end

end

class King < Stepper
  def initialize(position)
    steps = [[0,1],[0,-1],[1,0],[-1,0],[-1,-1],[-1,1],[1,-1],[1,1]]
    super(position, steps)
  end
end


class Knight < Stepper
  def initialize(position)
    steps = [[1,2],[-2,1],[2,1],[-1,2],[-2,-1],[-1,-2],[1,-2],[2,-1]]
    super(position, steps)
  end
end


class Bishop < Piece
end


class Queen < Piece
end


class Rook < Piece
end


class Pawn < Piece
end



#knight = Knight.new([3,3])
#king = King.new([5,4])

#p knight.possible_positions
#p king.possible_positions

s = Slider.new([4, 4], "rook")
p s.rook_positions