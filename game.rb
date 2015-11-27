=begin
  This class controls the user interaction and runs the chess game.
=end

require "./board.rb"

class Game
  attr_reader :board

  #hash for converting File letter to array column index
  @@file_num = {
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

  def initialize
    @board = Board.new
    @board.start_board
  end

  def play
    puts
    puts "Welcome to CLI Chess!"
    puts "---------------------"
    puts "Instructions: Type in moves using coordinates"
    puts "For example: White can type 'b1 c3' to move"
    puts "the knight from its starting location, B1, to"
    puts "its final location, C3. Uppercase and lowercase both"
    puts "work. Bullet points indicate black squares."
    puts
    puts "NOTE: REGARDLESS OF HOW THE PIECE COLORS ARE RENDERED,"
    puts "WHITE STARTS ON BOTTOM, BLACK STARTS ON TOP!"
    puts
    @board.print_board

    turn = 1
    color = "white"
    until @board.end_conditions?(color) #win condition
      if turn % 2 == 1
        print "Move #{turn} [White's move]: "
      else
        print "Move #{turn} [Black's move]: "
      end
      input = gets.strip
      #puts
      move = valid_input?(input)
      if move
        #check if white's move
        if turn % 2 == 1 && @board[move[0]].color == "white"
          if move_piece(move)
            @board.move_record << move
            #puts @board.move_record.inspect
            @board.update_board
            @board.print_board
            turn += 1
            color = "black"
          end
        #check black's move
        elsif turn % 2 == 0 && @board[move[0]].color == "black"
          if move_piece(move)
            @board.move_record << move
            #puts @board.move_record.inspect
            @board.update_board
            @board.print_board
            turn += 1
            color = "white"
          end
        else
          puts "Move a correct colored piece!"
          puts
        end
      else
        next
      end
    end
    print "Checkmate! "
    puts color == "white" ? "Black victory!" : "White victory!"
  end

  #checks for valid user input
  def valid_input?(user_input)
    #regex for valid input
    proper_format = /^[a-zA-Z][1-8] [a-zA-Z][1-8]$/ #Example: A1 B2 or c3 G4
    if proper_format.match(user_input)
      move = user_input.split(" ")
      if move[0] == move[1] #if start and end position are the same
        puts "Not a valid move! The start and end positions are the same!"
        puts
        return false
      else #else check other cases
        start_pos = [move[0][1].to_i - 1, @@file_num[move[0][0]]]
        end_pos = [move[1][1].to_i - 1, @@file_num[move[1][0]]]
        if !@board[start_pos] #if nothing at start position
          puts "There is no piece at #{move[0]}!"
          puts
          return false
        else #return the move if it passes all other cases
          puts
          return [start_pos, end_pos]
        end
      end
    else
      puts
      puts "Not a valid input!"
      puts
      return false
    end
  end

  #checks if "move" is within set of move_list of that particular piece
  #if so, then move the piece
  #then update its position (pos) and move history (move_history)
  def move_piece(move)
    curr_piece = @board[move[0]]
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
          @board[captured_pawn_pos] = nil
        end
      end
      @board[move[1]] = curr_piece
      @board[move[0]] = nil
      curr_piece.move_history << move
      curr_piece.pos = move[1]
      #if castling, move rook too
      if curr_piece.class == King && (move[0][1] - move[1][1]).abs == 2
        #find the appropriate rook to move
        start_rank = move[0][0]
        start_file = move[1][1] == 2 ? 0 : 7
        start_pos = [start_rank, start_file]
        rook = @board[start_pos]
        #determine its final location, then move it.
        end_file = start_file == 0 ? 3 : 5
        end_pos = [start_rank, end_file]
        @board[end_pos] = rook
        @board[start_pos] = nil
        rook.move_history << end_pos
        rook.pos = end_pos
      end
      return true
    else
      puts "Your king is still in check!" if @board.in_check?(curr_piece.color)
      puts "Not a legal move for this #{curr_piece.color} #{curr_piece.class}!"
      puts
      return false
    end
  end
end

#create a new game instance and start game!
#game = Game.new
#game.play
