class Knight < Piece

  def initialize(pos, color)
    @pos = pos
    @color = color
    @color == "white" ? @unicode = "\u2658" : @unicode = "\u265E"
    @delta = [[2,1], [1,2], [-1,2], [-2,1], [-2,-1], [-1,-2], [1,-2], [2,-1]]
    @move_history = []
    @move_list = []
  end

  #generates possible moves for knight
  def generate_moves
    @delta.each do |step|
      new_pos = [@pos[0] + step[0], @pos[1] + step[1]]
      @move_list << new_pos if valid_coord?(new_pos)
    end
  end

end
