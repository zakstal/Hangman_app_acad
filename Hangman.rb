
module Voice

  def v
    {
      :Hchoose    => "Choose a word press",
      :Hguess     => "Geuss a letter",
      :Inalid     => "Choose a valid letter",
      :Cright?    => ("Type the letter position\n\tor positions if
                     right.\nenter multiple positoions at once
                      \n\n #{self.show_positions}"),
      :BeenChosen => "That letter has been chosen",
      :Tryagain   => "Nope, try again",
      :Won        => "You won!, great job",
      :Lost       => "You Suck because you lost"
    }

  end

  def say(word)
    puts v[word]
  end

  def say_get(word)
    puts v[word]
    gets.chomp
  end

end

class Dictionary
  attr_accessor :word_bank
  def get_dictionary
    File.readlines("dictionary.txt").map(&:chomp)
  end

  def initialize(dic = [])
    @dictionary = (dic.empty? ? get_dictionary : dic )
  end

  def pick_most_frequent_letter(new_word)
    letters_freq = Hash.new {|h,k| h[k] = 0}

      find_alternate_words(new_word).each do |word|
        word.each_char do |char|

          letters_freq[char] += 1
        end
      end
      letters_freq.reject!{|letter,v| new_word.include?(letter)}
      letters_freq.sort_by{|k,frequency| frequency}
          .last
          .first
  end

  def get_random_word
    self.dictionary.sample
  end


  protected
  attr_accessor :dictionary

  def get_same_length_words(new_word)
    self.dictionary.select{|word|
          word.length == new_word.length}
  end

  def find_alternate_words(new_word)
    get_same_length_words(new_word).select { |word|

      alternate_word?(word,new_word)
    }
  end

  def alternate_word?(word,new_word)
    is_alternate = true

      word.each_char.with_index do |char1,index1|
        new_word.each_char.with_index do |char2,index2|

          next if char2 == "_"
          if index1 == index2
            if  new_word.include?(char1) && char2 == "_" || char1 != char2
              is_alternate = false
              break
            end
          end

        end
      end

      is_alternate
  end

end

class Player

  include Voice
  attr_accessor :letters_guessed, :word_hidden

  def initialize
    @word = ""
    @letters_guessed = []
    @word_hidden = ""
  end

  def hide_word
    @word.length.times{ self.word_hidden << "_"}
  end

  def unhide_letter(letter)
    if self.word.include?(letter)

      index = self.word.index(letter)
      self.word_hidden[index] = letter
    end
  end

  def won?
    self.word_hidden.include?("_") == false
  end

  def invalid(letter)
    all_letters = ("a".."z").to_a
    return true if letter.length > 1
    return true if !all_letters.include?(letter.downcase)
  end

  def word_length
    self.word_hidden.length
  end

  def receives(answer)
    if !answer.nil?
      answer.split("").each do |letter|

        unhide_letter(letter)
      end
    else
      say :Tryagain
    end

  end

  def already_guessed?(letter)
   true if letters_guessed.include?(letter) || self.word_hidden.include?(letter)
  end


  attr_accessor :word

end

class HumanPlayer < Player

  def choose_word
    @word = say_get :Hchoose
    hide_word
  end

  def guess(secret_word)
    # secret_word is not used for Human player
    letter = ""
    loop do
      letter = say_get :Hguess
      if invalid(letter)
         say :Invalid
      elsif already_guessed?(letter)
         say :BeenChosen
      else
        break
      end
    end
    letters_guessed << letter if letter != ""
    letter
  end

  def answers(blank)
    # blank is not used here
    letter = say_get :Cright?
    if letter != ""
      unhide_letter(letter)
      letter
    end
  end

  def show_positions
     @word.split("").join(" ")
      self.word_hidden.split("")
     (1..word_hidden.length).to_a
  end

end

class ComputerPlayer < Player

  attr_reader :dictionary

  def initialize
    @dictionary = Dictionary.new
    super
  end

  def choose_word
    self.word = self.dictionary.get_random_word
    hide_word
    p self.word
  end

  def guess(secret_word)
    letter = ""
    until !already_guessed?(letter)
      letter = self.dictionary.pick_most_frequent_letter(secret_word)
    end
    letters_guessed << letter if letter != ""
    letter
  end

  def answers(letter)
      if self.word.include?(letter)
        unhide_letter(letter)
        letter
      end
  end

end

class Game
  include Voice
  # include Style
  attr_accessor :player1, :player2, :turn

  PLAYERS = {:P1 => :C,
             :P2 => :H}

  TURNS   =  8

  def initialize(options = {})
    players = PLAYERS.merge(options) if !options.nil?
    @player1 = new_player(players[:P1])
    @player2 = new_player(players[:P2])
    @turn    = 1
  end

  def play
    player1.choose_word
    player2.word_hidden = player1.word_hidden
    until game_over?
      self.show
      letter = player2.guess(player1.word_hidden)
      answer = player1.answers(letter)
               player2.receives(answer)
               player2.letters_guessed = player1.letters_guessed
      self.turn += 1
    end
    ending
  end

  def show
    puts player1.word_hidden
    puts player2.letters_guessed.join(" ")
  end

  def game_over?
    TURNS == self.turn || player2.won?
  end

  def ending
    return say :Won if player2.won?
    say :Loose
  end

  protected

  def new_player(option)
    return HumanPlayer.new if option == :H
    return ComputerPlayer.new if option == :C
  end

end
