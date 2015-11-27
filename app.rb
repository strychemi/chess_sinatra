require 'sinatra'
require './game.rb'

#initialization
set :prompt, "Welcome to CLI Chess!"\
"---------------------"\
"Instructions: Type in moves using coordinates"\
"For example: White can type 'b1 c3' to move"\
"the knight from its starting location, B1, to"\
"its final location, C3. Uppercase and lowercase both"\
"work. Bullet points indicate black squares."\
"NOTE: REGARDLESS OF HOW THE PIECE COLORS ARE RENDERED,"\
"WHITE STARTS ON BOTTOM, BLACK STARTS ON TOP!"

get '/' do
  init_prompt = settings.prompt
  erb :index, :locals => {
    :init_prompt => init_prompt
  }
  throw params.inspect
end
