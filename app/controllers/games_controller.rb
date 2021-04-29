require 'open-uri'
require 'json'

class GamesController < ApplicationController
  before_action :initialize_session

  def new
    # generate random grid of 10 letters
    $letters = generate_grid
    @current_score = current_score
  end

  def score
    @word = params[:word]

    if included?(@word.upcase, $letters)
      if english_word?(@word)
        @results = "Congratulations #{@word.upcase} is a valid English word!"
        increment_score_count(@word)
      else
        @results = "Sorry but #{@word.upcase} does not seem to be a valid English word..."
        @final_score = "Final Score: #{current_score}"
        session[:score_count] = 0
      end
    else
      separate_letters = $letters.join(', ')
      @results = "Sorry but #{@word.upcase} can't be built out of #{separate_letters}"
      @final_score = "Final Score: #{current_score}"
      session[:score_count] = 0
    end
  end

  private # can't route to the private/helper methods

  def generate_grid
    Array.new(10) { ('A'..'Z').to_a.sample.upcase }
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def english_word?(word)
    response = URI.open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    json['found']
  end

  def initialize_session
    session[:score_count] ||= 0 # initialize score count
  end

  def increment_score_count(word)
    # session[:score_count] += word.length * word.length
    word.upcase.each_char do |letter|
    session[:score_count] += SCORING[letter.to_sym]
  end
  end

  def current_score
    session[:score_count]
  end
end

SCORING = {
    A: 1,   B: 3,   C: 3,   D: 2,   E: 1,   F: 4,   G: 2,   H: 4,   I: 1,
    J: 8,   K: 5,   L: 1,   M: 3,   N: 1,   O: 1,   P: 3,   Q: 10,  R: 1,
    S: 1,   T: 1,   U: 1,   V: 4,   W: 4,   X: 8,   Y: 4,   Z: 10
  }
# => Questions
# global variable $letters, not @letters?
# Why POST request? Why not use GET?
# hidden_field_tag - not understanding why we need this?
# reason for authenticy token
