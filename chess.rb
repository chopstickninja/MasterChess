require 'colorize'


class ChessGame
  attr :player1, :player2

  def self.new_game
  end

  def get_move
    puts "Make a move! E.g. F2, F3" #[f,2][f,3]
    player_moves = gets.chomp.downcase.split(",")
    move = []

    player_moves.each do |player_move|
      move << [player_move[0].ord - "a".ord, player_move[1].to_i - 1]
    end
    move
  end

  def initialize
    @board = Board.new
  #   @current_player = player1
  #   @player1 = player1
  #   @player2 = player2
  end

  def play
    puts "You're playing chess..."
    until @board.won?
      play_turn
    end
  end

  def change_player
    @current_player = @player2 if (@current_player == @player1)
    @current_player = @player1
    #FIX THIS SHIT
  end

  def play_turn
    #make sure color matches player whose turn it is
    puts @board
    move = get_move
    @board.move(move[0], move[1])
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


class Piece
  attr_accessor :position, :color, :board

  def initialize(position, color, board)
    @position = position
    @color    = color
    @board    = board

    update_board
  end

  def legal_move?(new_position)
    other = @board[new_position]
    return false if self.out_of_bounds?(new_position)
    return false if !@board.empty?(new_position) && self.color == other.color

    true
  end

  def move(new_pos)
    @board[self.position] = "."
    @position             = new_pos

    self.update_board
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

  def update_board
    @board[@position] = self
  end

  def out_of_bounds?(pos)
    x, y = pos
    (x > 7 || x < 0 ) || (y > 7 || y < 0)
  end
end


class Stepper < Piece
  def possible_positions
    p "Stepper Possible Positions"
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

      until self.out_of_bounds?(new_position)
        if @board.empty?(new_position) || @board[new_position].color != self.color
          possible_positions << new_position unless self.out_of_bounds?(new_position)
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
   if @color == :white
     diagonals = [[-1, 1], [1, 1]]
   else
     diagonals = [[-1, -1], [1, -1]]
   end

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


chess = ChessGame.new
chess.play