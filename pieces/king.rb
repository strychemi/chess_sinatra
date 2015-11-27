class King < Piece

  def initialize(pos, color)
    @pos = pos
    @color = color
    @color == "white" ? @unicode = "\u2654" : @unicode = "\u265A"
    @delta = [[1,-1], [1,0], [1,1], [0,1], [-1,1], [-1,0], [-1,-1], [0,-1]]
    @move_history = []
    @move_list = []
  end

  #generates possible legal moves for King
  def generate_moves
    @delta.each do |step|
      new_pos = [@pos[0] + step[0], @pos[1] + step[1]]
      @move_list << new_pos if valid_coord?(new_pos)
    end
    #if castling conditions are met, add the appropriate king moves
    #if king hasn't moved and is not currently in check
    if @move_history.empty? && !@board.in_check?(@color)
      #select rooks that are the same color as king and hasn't moved yet
      rooks = @board.all_pieces.select { |piece| piece.class == Rook && piece.color == @color && piece.move_history.empty? }
      rooks.each do |rook|
        #for each rook, check if there is no piece between it and the king
        king_file = @pos[1]
        rook_file = rook.pos[1]
        between = rook_file < king_file ? ((rook_file + 1)...king_file) : ((king_file + 1)...rook_file)
        #if the squares between the current rook and king are are empty
        #check if the king's castle path for any potential checks
        #if
        if between.all? { |file| @board[[@pos[0], file]].nil? }
          if rook_file < king_file
            if between.all? { |file| into_check?([@pos[0], file]) == false }
              @move_list << [@pos[0], 2]
            end
          else
            if between.all? { |file| into_check?([@pos[0], file]) == false }
              @move_list << [@pos[0], 6]
            end
          end
        end

      end
    end
  end

end
