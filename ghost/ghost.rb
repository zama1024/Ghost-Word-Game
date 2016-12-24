require "byebug"
require "Set"

class Game
  attr_reader :fragment
  attr_accessor :current_player, :previous_player

  def initialize(player1, player2, dictionary)
    @player1 = Player.new(player1)
    @player2 = Player.new(player2)
    @fragment = ""
    @current_player = @player1
    @previous_player = @player2
    @dictionary = Set.new(File.readlines(dictionary).map!(&:chomp))
  end

  def play_round
    until game_over? do
      guessed_letter = current_player.guess
      @fragment << guessed_letter
        until is_in_dictionary(fragment) do
          @fragment.chop
          guessed_letter = current_player.alert_invalid_guess
          @fragment << guessed_letter
        end
        puts "#{fragment}"
      self.switch_players
    end
    puts "Game over! Winner is #{current_player.name}"
  end

  def game_over?
    @dictionary.include?(fragment)
  end

  def switch_players
    if @current_player == @player1
      @current_player = @player2
      @previous_player = @player1
    elsif @current_player == @player2
      @current_player = @player1
      @previous_player = @player2
    end
  end


  def is_in_dictionary(frag)
    @dictionary.each { |el| return true if el.index(frag) == 0 }
    false
  end


end

class Player
  attr_reader :name
  def initialize(name)
    @name = name
  end

  def guess
    puts "Hey #{name}, Please choose your letter"
    guessed_letter = gets.chomp
    guessed_letter
  end

  def alert_invalid_guess
    puts "Invalid guess, please choose a different letter"
    guessed_letter = gets.chomp
    guessed_letter
  end
end

game = Game.new("Saima", "Farshid", "dictionary.txt")
game.play_round
