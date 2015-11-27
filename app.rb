require 'sinatra'
require 'sinatra/reloader'
require './game.rb'
require './board.rb'
#initialization
set :start, false
set :game, nil
set :turn, 1
set :color, "white"

get '/' do
  #reset msgs
  move_error = ""

  #check end conditions (checkmate, stalemate, etc.)


  #check start game conditions
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

  #check valid user move inputs
  #if valid move, save it to "move" variable
  not_empty_move = params["user_move"] && params["user_move"] != ""
  if not_empty_move
    move = params["user_move"].split(" ").map(&:to_i) if valid_input?(params["user_move"])
  end

  if move && !settings.game.nil?
    #check if white's move
    if settings.turn % 2 == 1 && settings.game.board[move[0]].color == "white"
      if move_piece(move)
        settings.game.board.move_record << move
        #puts @board.move_record.inspect
        settings.game.board.update_board
        #settings.game.board.print_board
        settings.turn += 1
        settings.color = "black"
      end
    #check black's move
    elsif turn % 2 == 0 && @board[move[0]].color == "black"
      if move_piece(move)
        settings.game.board.move_record << move
        #puts @board.move_record.inspect
        settings.game.board.update_board
        #settings.game.board.print_board
        settings.turn += 1
        settings.color = "white"
      end
    else
      move_error = [true, "Move a correct colored piece!"]
    end
  end

  if settings.start
    board = settings.game.board
    erb :play, :locals => {
      :board => board,
      :turn_count => settings.turn,
      :move_error => move_error
    }
  else
    erb :index, :locals => {
      :not_bot_msg => not_bot_error
    }
  end

end

#checks for valid user input
def valid_input?(user_input)
  file_num = {
    "A" => 0,
    "B" => 1,
    "C" => 2,
    "D" => 3,
    "E" => 4,
    "F" => 5,
    "G" => 6,
    "H" => 7,
    "a" => 0,
    "b" => 1,
    "c" => 2,
    "d" => 3,
    "e" => 4,
    "f" => 5,
    "g" => 6,
    "h" => 7
  }
  #regex for valid input
  proper_format = /^[a-zA-Z][1-8] [a-zA-Z][1-8]$/ #Example: A1 B2 or c3 G4
  puts user_input
  puts proper_format.match(user_input)
  if proper_format.match(user_input)
    move = user_input.split(" ")
    if move[0] == move[1] #if start and end position are the same
      return false
    else #else check other cases
      start_pos = [move[0][1].to_i - 1, file_num[move[0][0]]]
      end_pos = [move[1][1].to_i - 1, file_num[move[1][0]]]
      if !settings.game.nil? && !settings.game.board[start_pos] #if nothing at start position
        return false
      else #return the move if it passes all other cases
        return [start_pos, end_pos]
      end
    end
  else
    return false
  end
end

#checks if "move" is within set of move_list of that particular piece
#if so, then move the piece
#then update its position (pos) and move history (move_history)
def move_piece(move)
  curr_piece = settings.game.board[move[0]]
  if curr_piece.non_check_moves.include?(move[1])
    #if en passant, remove captured piece
    if curr_piece.class == Pawn
      #puts curr_piece.can_en_passant?
      #puts "HELKFDSJLFKD"
      if curr_piece.can_en_passant?
        #puts "HOMFDMSKFDFLSJFKDSLFJSDKLF JDSFKLSJFKLEJ FE FJSKLF"
        rank = move[0][0]
        col = move[1][1]
        captured_pawn_pos = [rank,col]
        #puts captured_pawn_pos.inspect
        settings.game.board[captured_pawn_pos] = nil
      end
    end
    settings.game.board[move[1]] = curr_piece
    settings.game.board[move[0]] = nil
    curr_piece.move_history << move
    curr_piece.pos = move[1]
    #if castling, move rook too
    if curr_piece.class == King && (move[0][1] - move[1][1]).abs == 2
      #find the appropriate rook to move
      start_rank = move[0][0]
      start_file = move[1][1] == 2 ? 0 : 7
      start_pos = [start_rank, start_file]
      rook = settings.game.board[start_pos]
      #determine its final location, then move it.
      end_file = start_file == 0 ? 3 : 5
      end_pos = [start_rank, end_file]
      settings.game.board[end_pos] = rook
      settings.game.board[start_pos] = nil
      rook.move_history << end_pos
      rook.pos = end_pos
    end
    return true
  else
    puts "Your king is still in check!" if settings.game.board.in_check?(curr_piece.color)
    puts "Not a legal move for this #{curr_piece.color} #{curr_piece.class}!"
    puts
    return false
  end
end
