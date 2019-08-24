require "yaml"

class Dictionary
  @@file = File.readlines("words.txt")
  def pick_word
    @word = @@file[rand(@@file.length)].downcase.gsub(/[\n\r]/,"")
  end
end

class Display
  def initialize
    display_rules
  end
  def display_hangman(fail)
    fail_1 = "               ____________"
    fail_2 = "               | /        |"
    fail_3 = "               |/         |"
    fail_4 = "               |          O"
    fail_5 = "               |          |"
    fail_6 = "               |         /|"
    fail_7 = "               |         /|\\"
    fail_8 = "               |         / "
    fail_9 = "               |         / \\"
    end_game = "              //_____________"
    case fail
    when 1 then puts "#{fail_1}\n\n\n\n\n\n\n\n"
    when 2 then puts "#{fail_1}\n#{fail_2}\n\n\n\n\n\n\n"
    when 3 then puts "#{fail_1}\n#{fail_2}\n#{fail_3}\n\n\n\n\n\n"
    when 4 then puts "#{fail_1}\n#{fail_2}\n#{fail_3}\n#{fail_4}\n\n\n\n\n"
    when 5 then puts "#{fail_1}\n#{fail_2}\n#{fail_3}\n#{fail_4}\n#{fail_5}\n\n\n\n"
    when 6 then puts "#{fail_1}\n#{fail_2}\n#{fail_3}\n#{fail_4}\n#{fail_6}\n\n\n\n"
    when 7 then puts "#{fail_1}\n#{fail_2}\n#{fail_3}\n#{fail_4}\n#{fail_7}\n\n\n\n"
    when 8 then puts "#{fail_1}\n#{fail_2}\n#{fail_3}\n#{fail_4}\n#{fail_7}\n#{fail_8}\n\n\n"
    when 9 then puts "#{fail_1}\n#{fail_2}\n#{fail_3}\n#{fail_4}\n#{fail_7}\n#{fail_9}\n#{end_game}\n\n"
    else puts "\n\n\n\n\n\n\n\n\n"
    end
  end
  
  def get_type_of_data
    puts "Choose:\n>>New Game(Enter 1)\n>>Load Game(Enter 2)"
    game_type = gets.chomp
    unless game_type == "1" || game_type == "2"
      puts "Choose:\n>>New Game(Enter 1)\n>>Load Game(Enter 2)"
      game_type = gets.chomp
    end
    return game_type
  end



  def display_menu
    puts ">>rules"
    puts ">>save"
    puts ">>back"
  end

  def display_win
    puts "\nYay! You won the game, you saved the hangman!"
  end

  def display_loss
    puts "\nOh, no! Hangman couldn't be saved!"
  end

  def display_rules
    puts "***************************************"
    puts "**** Welcome To The Hangman Game! *****"
    puts "***************************************"
    puts "======================================="
    puts "************ Instructions *************"
    puts "***************************************"
    puts "1. The objective of the game is to guess"
    puts "letters to a secret word. The secret word"
    puts "is represented by a series of horizontal"
    puts "lines indicating its length. "
    puts "For example:"
    puts "If the secret word it 'chess', then it will "
    puts "be displayed as:"
    puts "_ _ _ _ _ \n "
    puts "2. You are given 9 chances. For each incorrect"
    puts "guess, the chances will decrease by 1. For each correct"
    puts "guess, the part of the secret word are revealed"
    puts "For example: If your guess is 's' then the result"
    puts "of the guess will be:"
    puts "_ _ _ s s \n "
    puts "3. When you guessed all the correct letters to the secret word"
    puts "or when you are out of chances, it will be game over."
    puts "4. Any time during the game, if you would like to save"
    puts "your progress, type 'save--' without the quotes"
  end

  def display_output(game_data)
    game_data[:output].each { |char|
      if game_data[:visible][char]
        print "#{char} "
      else
        print "_ "
      end
    }
    puts "\n\nGuesses left : #{game_data[:guesses]}"
    puts "Wrong Guesses: #{game_data[:misses].join(', ')}"
    puts "Type '>menu' to go to menu\n"
  end

end



class Game
  attr_accessor :game_data
  
  def initialize(game_data = {
      misses: [],
      guesses: 9,
      secret_word: '',
      output: [],
      visible: {},
      win?: false,
    })
    @game_data = game_data
  end


  def save_game
    if File.exist? "save_data.yml"
      File.open("save_data.yml", "w") { |f| f.write(@game_data.to_yaml)}
    else
      File.open("save_data.yml", "w") { |f| f.write(@game_data.to_yaml)}
    end
  end


  def handle(input, screen)
    if input == ">menu"
      screen.display_menu
      choice = gets.chomp.downcase
      case choice
      when "save"
        save_game
      when "rules"
        screen.display_rules
        play_round screen
      when "back"
        play_round screen        
      end
    else
      unless ("a".."z") === input || ("A".."Z") === input || input.gsub(/\s+/, "") == @game_data[:secret_word] || input.length == @game_data[:secret_word].length
        puts "Please enter a proper, single character guess, or the whole word"
        input = gets.chomp
      end
      update_output input, screen
    end
  
  end


  def used?(letter)
    @game_data[:visible][letter]
  end


  def set_visible(word)
    rand(1..3).times {
      @game_data[:visible][word[rand(word.length)]] = true
    }
  end

  
  def play_round(screen)

    screen.display_hangman 9 - @game_data[:guesses]
    screen.display_output @game_data
    
    guess = gets.chomp
    handle guess, screen

  end


  def win?
    @game_data[:output].all? { |char| @game_data[:visible][char] != nil }
  end
  

  def end_game(screen)
    screen.display_win if @game_data[:win?]
    screen.display_loss if @game_data[:guesses] == 0
    puts "The secret word is -> #{@game_data[:secret_word]}"
  end


  def update_output(guess, screen)
    if guess == @game_data[:secret_word]
    
      @game_data[:output] = @game_data[:secret_word].split('')
      @game_data[:win?] = true
      screen.display_win
    
    elsif used? guess
    
      puts "You've already guessed this letter"
    
    elsif @game_data[:secret_word].include?(guess) && guess.length == 1
    
      @game_data[:visible][guess] = true
      @game_data[:win?] = true if win?
    
    else
    
      puts "Oops! Wrong guess"
      @game_data[:misses].push guess
      @game_data[:guesses] -= 1
    
    end
  end
  

  def play_game(screen)
    while !@game_data[:win?] && @game_data[:guesses] != 0
      play_round screen
    end
    screen.display_hangman 9 - @game_data[:guesses]
  end
  
end


def pre_game_initialize
  game = Game.new
  screen = Display.new
  type_of_game = screen.get_type_of_data
  if type_of_game == "1"
    game.game_data[:secret_word] = Dictionary.new.pick_word
    game.game_data[:output] = game.game_data[:secret_word].split('')
    game.set_visible game.game_data[:secret_word]
    # puts game.game_data
    game.play_game screen
    game.end_game screen
  elsif type_of_game == "2"
    if File.exist? "save_data.yml"
      game.game_data = YAML.load File.open "save_data.yml"
      game.play_game screen
      game.end_game screen
    else
      puts "Couldn't find any saved data. Starting new game"

      game.game_data[:secret_word] = Dictionary.new.pick_word
      game.game_data[:output] = game.game_data[:secret_word].split('')
      game.set_visible game.game_data[:secret_word]
      # puts game.game_data
      game.play_game screen
      game.end_game screen

    end
  end
end

pre_game_initialize