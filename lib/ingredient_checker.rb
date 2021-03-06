require 'net/http'
require 'json'

URL = 'http://www.veganpeace.com/ingredients/ingredients.htm'

class IngredientChecker
  def self.check(ingredient)
    return 'Please add an ingredient for me to check.' if ingredient.empty?

    url = URI.parse(URL)
    req = Net::HTTP::Get.new(url.to_s)

    begin
      begin
        res = Net::HTTP.start(url.host, url.port) do |http|
          http.request(req)
        end
      rescue Exception
        'Sorry, I can\'t get a response from the veganpeace.com right now. Please try again later and contact the developer if the problem persits.'
      end

      list = res.body.split("\n")
      ingredient = ingredient.downcase

      matches = list.select { |line| line.downcase.include? ingredient }
      matches = matches.select { |line| title(line).downcase.include? ingredient }
      matches.sort! { |a, b| a.downcase.index(ingredient) <=> b.downcase.index(ingredient) }

      if matches.empty?
        return 'Hey, sorry, I could not find an ingredient by that name :(. Did you spell it correctly?'
      end

      match = matches[0]

      if match.include? '(A)'
        "Hey, it looks like #{ingredient} is animal-based... Sorry about that :("
      elsif match.include? '(V)'
        "#{ingredient.capitalize} is vegan... Yay! Go, have at it! :D"
      elsif match.include? '(B)'
        "Hmm, this one is tricky. #{ingredient.capitalize} exists in both animal and vegan versions... :S"
      else
        "Hmm, I'm confused, I found the ingredient, but no info on whether it's vegan or not"
      end
    rescue Exception
      'Sorry, something went wrong. Please contact contact the developer if this problem persists.'
    end
  end

  def self.title(line)
    label_index = [line.index('(A)'), line.index('(B)'), line.index('(V)')].compact.min
    line[0..label_index]
  rescue ArgumentError
    ''
  end
end
