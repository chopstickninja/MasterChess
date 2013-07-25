require 'colorize'
require 'debugger'

# My Filesrequire "pieces"

require './board.rb'
require './pieces.rb'
require './player'


class ChessGame
  attr :player1, :player2, :board

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

  def initialize(custom_positions = nil)

    if custom_positions
      @board = Board.new(custom_positions)# unless custom_positions.nil?
    else
      @board = Board.new #if custom_positions.nil?
    end
  end

  def play
    puts "You're playing chess..."
    until @board.won?
      play_turn

      #p "Has the board been won? #{@board.won?}"
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


chess = ChessGame.new
chess.play


# p chess.board[[0, 1]].class
# p chess.board[[0, 1]].possible_positions
# puts
#
# p chess.board[[1, 0]].class
# p chess.board[[1, 0]].possible_positions
#
# p chess.board[[2, 0]].class
# p chess.board[[2, 0]].possible_positions
#
# p chess.board[[3, 0]].class
# p chess.board[[3, 0]].possible_positions
#
# p chess.board[[4, 0]].class
# p chess.board[[4, 0]].possible_positions