require 'sinatra'
require 'sinatra/reloader'
require './game.rb'
#initialization
set :start, false
set :game, nil
set :turn, 1
set :color, "white"

get '/' do
  #Condition to start the game
  if !settings.start
    not_bot = params["start_game"]
    if not_bot == "Start"
      if not_bot == "Start"
        settings.game = Game.new
        settings.start = true
      end
    elsif not_bot.nil? || not_bot == ""
    else
      not_bot_error = "ERROR: INPUT NOT VALID! TYPE \"Start\" CORRECTLY!"
    end
  end


  if settings.start
    board = settings.game.board
    erb :play, :locals => {
      :board => board
    }
  else
    erb :index, :locals => {
      :not_bot_msg => not_bot_error
    }
  end

end
