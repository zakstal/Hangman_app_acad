require './hangman'

def dictionary_test
  dic = %w(that all can sell fun clown sun san faz sad)
  word = "man"
  new_word = "_a_"
  diction = Dictionary.new(dic)
  # diction.send(:dictionary = dic)

  puts "find the most frequnt letter"
  p diction.pick_most_frequent_letter(new_word) == "n"

  puts "gets a random word from dictioanry"
  word = diction.get_random_word
  p dic.include?(word)

  # puts "gets words of same length"
#   p diction.get_same_length_words(new_word) == %w(all can fun sun san faz sad)
#
#   puts "finds alternate words"
#   p diction.send(find_alternate_words(new_word)) == %w(can san faz sad)
#

end



  dictionary_test