class Pawn < Piece

  def initialize(pos, color)
    @pos = pos
    @color = color
    @color == "white" ? @unicode = "\u2659" : @unicode = "\u265F"
    @delta = [
                [ [1,-1], [1,1], [1,0] ], #white pawn deltas
                [ [-1,-1], [-1,1], [-1,0] ] #black pawn deltas
              ]
    @move_history = []
    @move_list = []
    @en_passant = false
  end

  #generates possible legal moves for Pawn
  def generate_moves
    pick_delta.each do |step|
      #regular move opening for pawn
      if step == [1,0] || step == [-1,0]
        new_pos = [@pos[0] + step[0], @pos[1] + step[1]]
        if valid_coord?(new_pos) && @board[new_pos].nil?
          @move_list << new_pos
        end
      end
      #opening move for pawn (double step)
      if step == [1,0] && @move_history.empty? || step == [-1,0] && @move_history.empty?
        new_pos1 = [@pos[0] + step[0], @pos[1] + step[1]]
        new_pos2 = [@pos[0] + step[0] * 2, @pos[1] + step[1] * 2]
        if valid_coord?(new_pos1) && @board[new_pos1].nil? && valid_coord?(new_pos2) && @board[new_pos2].nil?
          @move_list << new_pos2
        end
      end
      #capture move for pawn
      if [[1,1],[1,-1], [-1,1],[-1,-1]].include?(step)
        new_pos = [@pos[0] + step[0], @pos[1] + step[1]]
        #if there's a piece of opposing color capture it
        if valid_coord?(new_pos) && !@board[new_pos].nil?
          other_piece = @board[new_pos]
          @move_list << new_pos if @color != other_piece.color
        end
        #if it's an empty square, check for en passant
        if valid_coord?(new_pos) && @board[new_pos].nil?
          adjacent_square = [@pos[0], @pos[1] + step[1]]
          #puts adjacent_square.inspect
          if valid_coord?(adjacent_square) && @board[adjacent_square].class == Pawn
            #puts new_pos.inspect
            @move_list << new_pos if @board[adjacent_square].en_passant_target?
          end
        end
      end
    end
  end

  #returns delta set based on pawn color
  def pick_delta
    @color == "white" ? @delta[0] : @delta[1]
  end

  #returns true if this pawn is an eligible en passant target
  def en_passant_target?
    #check if it's the recently moved piece
    last_moved_piece = @board.recent_piece
    #puts last_moved_piece
    return false unless self == last_moved_piece
    #if it is, then check if it double jumped
    end_rank = last_moved_piece.board.move_record.last.last[0]
    start_rank = last_moved_piece.board.move_record.last[-2][0]
    #check if the recently moved pawn double jumped in it's first move
    return true if last_moved_piece.move_history.length == 1 && ((end_rank - start_rank).abs == 2)
  end

  #returns true if this pawn can capture another pawn via en passant
  def can_en_passant?
    #check for en passant conditions
    #are there pawns next to this current pawn?
    left_side = [@pos[0], @pos[1] - 1]
    right_side = [@pos[0], @pos[1] + 1]
    #puts "#{@pos.inspect} #{left_side.inspect} #{right_side.inspect}"
    #are these valid squares? and are there pawns at these positions?
    if valid_coord?(left_side) && @board[left_side].class == Pawn
      #eligible for en passant capture?
      return @board[left_side].en_passant_target?
    elsif valid_coord?(right_side) && @board[right_side].class == Pawn
      #puts @board[right_side].en_passant_target?
      return @board[right_side].en_passant_target?
    else
      return false
    end
  end

end
