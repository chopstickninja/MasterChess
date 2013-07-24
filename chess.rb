require 'colorize'
require 'debugger'

# My Files
require './board.rb'
require './pieces.rb'
require './player'


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
    debugger
    puts @board
    move = get_move
    @board.move(move[0], move[1])
  end
end




chess = ChessGame.new
chess.play

{ [0, 0] => { :type => King, :color => :black },
  }