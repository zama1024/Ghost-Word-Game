require "Set"
require "colorize"
require "byebug"

class Game
  attr_reader :players_list
  attr_accessor :fragment, :current_player, :previous_player

  def initialize(list_of_players, dictionary = "dictionary.txt")
    @players_list = make_players(list_of_players)
    @fragment = String.new
    @current_player = players_list[0]
    @previous_player = players_list[-1]
    @dictionary = make_dictionary(dictionary)
  end

  def make_dictionary(dictionary)
    word_array = File.readlines(dictionary).map(&:chomp)
    word_set = Set.new(word_array)
  end

  def make_players(players_list)
    players_list.map { |name| Player.new(name) }
  end

  def self.start_game
    more_players_wanted = true
    list_all_players = Array.new
    list_all_players << Game.add_first_player

    while more_players_wanted
      list_all_players << Game.add_more_player
      more_players_wanted = Game.want_more_players?
    end

    game = Game.new(list_all_players)
    game.play_game
  end

  def self.add_first_player
    puts "Please enter a player name".cyan
    player_name = gets.chomp
  end

  def self.add_more_player
    puts "Please enter another player name".cyan
    player_name = gets.chomp
  end

  def self.want_more_players?
    puts "Enter 'y' for more players".cyan
    puts "Enter 'n' for no more players".cyan
    command = gets.chomp
    return false if command != "y"
    true
  end

  def play_game
    until @previous_player.losses == 5
      play_round
    end
    puts "Game over! #{previous_player.name} has lost the game\n".light_red
  end

  def play_round
    until round_over? do
      guessed_letter = current_player.guess
      @fragment << guessed_letter
      self.check_fragment_validity
      puts "Current fragment: #{fragment}\n".light_magenta
      self.switch_players
    end
    puts "Sorry #{previous_player.name}, #{fragment} is a word in the dictionary!\n".light_magenta
    puts "Round over! #{previous_player.name} has lost this round.\n".light_red
    puts "Press Enter to see standings!"
    gets.chomp
    update_game
  end

  def update_game
    @previous_player.losses += 1
    puts "Standings after this round:\n".cyan
    self.player_info
    @fragment = ""
    puts "Press Enter to play next round!"
    gets.chomp
  end

  def player_info
    @players_list.each do |player|
      puts "#{player.name}'s loss count = #{player.losses}\n".white
      if player.losses > 0
        puts "#{player.name} has reached #{'GHOST'[0..player.losses-1]}\n".white
        puts "REMINDER! YOU DON'T WANT TO REACH GHOST!\n".red
      else
        puts "#{player.name} has not pickud up any letter yet \n".white
      end
    end
  end

  def check_fragment_validity
    until is_in_dictionary(@fragment) do
      @fragment.chop!
      guessed_letter = current_player.alert_invalid_guess
      @fragment << guessed_letter
    end
  end

  def round_over?
    @dictionary.include?(fragment)
  end

  def switch_players
    @previous_player = current_player
    new_current_player_index = @players_list.index(current_player) + 1
    wrapped_ncp_index = new_current_player_index % players_list.length
    @current_player = @players_list[wrapped_ncp_index]
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
    puts "Hey #{name}, Please choose your letter:".yellow
    guessed_letter = gets.chomp
    while guessed_letter.length != 1 || guessed_letter == "\n"
      puts "Please enter a single letter".light_red
      guessed_letter = gets.chomp
    end
    guessed_letter
  end

  def alert_invalid_guess
    puts "Invalid guess, please choose a different letter"
    guessed_letter = gets.chomp
    guessed_letter
  end
end


Game.start_game
