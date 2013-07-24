require './board.rb'


class Piece
  attr_accessor :position, :color, :board

  def initialize(position, color, board)
    @position = position
    @color    = color
    @board    = board

    @board[@position] = self
  end

  def legal_move?(new_position)
    other = @board[new_position]
    return false if Board.out_of_bounds?(new_position)
    return false if !@board.empty?(new_position) && self.color == other.color

    true
  end

  def move(new_pos)
    @board[self.position] = nil
    @position             = new_pos

    @board[@position] = self
  end

  def to_s
    "#{self.class.name}"
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

end


class Stepper < Piece
  def possible_positions
    new_positions = []

    self.steps.each do |move|
      i, j = move
      x, y = @position
      new_position = [x + i, y + j]

      if self.legal_move?(new_position)
        new_positions << new_position
      end
    end

    new_positions
  end

end


class Slider < Piece
  def possible_positions
    new_position = @position
    possible_positions = []

    self.steps.each do |direction|
      x, y  = new_position
      i, j  = direction
      new_position  = [x + i, y + j]

      until Board.out_of_bounds?(new_position)
        if @board.empty?(new_position) || @board[new_position].color != self.color
          possible_positions << new_position unless Board.out_of_bounds?(new_position)
        end

        break if !@board.empty?(new_position)

        x, y  = new_position
        i, j  = direction
        new_position  = [x + i, y + j]
      end

        new_position = @position
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
#attacks diagonally, moves only forward. First move is 1 || 2, then 1.

 def possible_positions
   new_positions = []
   #self.board[diagonal forward] !empty?
   diagonals = @color == :white ? [[-1, 1], [1, 1]] : [[-1, -1], [1, -1]]

   diagonals.each do |diagonal|
     x, y = diagonal
     self_x, self_y = @position
     diagonal = x + self_x, y + self_y
     new_positions << diagonal if self.legal_move?(diagonal)
   end

   self.steps.each do |move|
     i, j = move
     x, y = @position

     new_position = [x + i, y + j]

     if @board.empty?(new_position)
       new_positions << new_position
     else
       break
     end
   end

   new_positions
 end

 def steps
   steps = [[0, 1]] if @color == :white
   steps = [[0, -1]] if @color == :black

   if @color == :white && @position[1] == 1
     steps += [[0, 2]]
   elsif @color == :black && @position[1] == 6
     steps += [[0, -2]]
   end

   steps
 end

end
