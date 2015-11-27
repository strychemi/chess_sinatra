=begin
  This class contains all of the logic for valid moves and piece movesets.

=end

class Piece
  attr_accessor :pos, :move_history, :move_list, :board
  attr_reader :color, :delta, :unicode

  def initialize(pos, color)
    @pos = pos
    @color = color
    @move_history = []
  end

  #checks if coord array [x,y] is valid space to move on
  #i.e. checks for "coord" for empty square or piece of opposing color
  def valid_coord?(coord)
    return false unless coord.all? { |x| x.between?(0, 7) }
    unless @board[coord].nil? #if square at coord not empty
      piece_at_coord = @board[coord]
      return false if self.color == piece_at_coord.color
    end
    true
  end

  #checks if the piece will move into a position that will lead to a check
  #assumes the piece being moved to pos is a valid move
  def into_check?(pos)
    #makes a complete duplicate copy of board array (not just a duplicate reference)
    temp_board = Marshal.load( Marshal.dump(@board) )
    #makes the move
    test_piece = temp_board[self.pos]
    temp_board[pos] = test_piece
    #updates board and piece position
    temp_board[self.pos] = nil
    test_piece.pos = pos
    #regenerates all moves for all pieces on test_board
    temp_board.update_board
    return temp_board.in_check?(test_piece.color)
  end

  #filters out any moves that lead to a self-check
  def non_check_moves
    self.move_list.reject { |move| into_check?(move) }
  end

end
