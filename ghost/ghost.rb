require "byebug"
require "Set"
require "colorize"

class Game
  attr_accessor :fragment, :current_player, :previous_player

  def initialize(player_list, dictionary = "dictionary.txt")
    @players_list = player_list.map { |name| Player.new(name)}
    @fragment = ""
    @current_player = @players_list[0]
    @previous_player = @players_list[@players_list.length - 1]
    @dictionary = Set.new(File.readlines(dictionary).map!(&:chomp))
  end

  def play_round
    until @previous_player.losses == 5
      until round_over? do
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
      puts "Round over! #{previous_player.name} lost this round".red
      @previous_player.losses += 1
      @fragment = ""
    end
    puts "Game over! #{previous_player.name} has lost the game".red
  end

  def round_over?
    @dictionary.include?(fragment)
  end

  def switch_players
    current_player_index = @players_list.index(current_player)
    @current_player = @players_list[(current_player_index + 1) % @players_list.length]
    @previous_player = @players_list[current_player_index]
  end

  def self.start_game
    more_players = true
    players_list = Array.new
    while more_players
      puts "Please enter a player name".white
      player_name = gets.chomp
      players_list << player_name
      puts "Enter 'Y' for more players and 'N' for no more players".green
      command = gets.chomp
      more_players = false if command != "y"
    end
    game = Game.new(players_list)
    game.play_round

  end


  def is_in_dictionary(frag)
    @dictionary.each { |el| return true if el.index(frag) == 0 }
    false
  end


end

class Player
  attr_reader :name
  attr_accessor :wins, :losses
  def initialize(name)
    @name = name
    @wins = 0
    @losses = 0
  end

  def guess
    puts "Hey #{name}, Please choose your letter".yellow
    guessed_letter = gets.chomp
    guessed_letter
  end

  def alert_invalid_guess
    puts "Invalid guess, please choose a different letter"
    guessed_letter = gets.chomp
    guessed_letter
  end
end


Game.start_game
