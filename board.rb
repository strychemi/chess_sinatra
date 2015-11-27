=begin
  This class controls the state of the game.
  board[0][0] represents the bottom left of the board where the white rook stands on a black square.
=end
require "./pieces.rb"

class Board
  attr_accessor :all_pieces, :board, :board_history, :move_record

  #initialize the starting chess board
  def initialize
    @board = Array.new(8) { Array.new(8) }
    @all_pieces = []
    @board_history = []
    @move_record = []
  end

  def start_board
    #initilize pawns
    (0..7).each do |n|
      @board[6][n] = Pawn.new([6,n], "black")
      @board[1][n] = Pawn.new([1,n], "white")
    end

    #initialize starting black pieces
    @board[7][0] = Rook.new([7,0], "black")
    @board[7][1] = Knight.new([7,1], "black")
    @board[7][2] = Bishop.new([7,2], "black")
    @board[7][3] = Queen.new([7,3], "black")
    @board[7][4] = King.new([7,4], "black")
    @board[7][5] = Bishop.new([7,5], "black")
    @board[7][6] = Knight.new([7,6], "black")
    @board[7][7] = Rook.new([7,7], "black")

    #initialize starting white pieces
    @board[0][0] = Rook.new([0,0], "white")
    @board[0][1] = Knight.new([0,1], "white")
    @board[0][2] = Bishop.new([0,2], "white")
    @board[0][3] = Queen.new([0,3], "white")
    @board[0][4] = King.new([0,4], "white")
    @board[0][5] = Bishop.new([0,5], "white")
    @board[0][6] = Knight.new([0,6], "white")
    @board[0][7] = Rook.new([0, 7], "white")

    #update board
    update_board
  end

  #prints board on command line interface
  def print_board
    @board.reverse.each_with_index do |rank, ri|
      rank_num = rank.length - ri
      print "#{rank_num} "
      rank.each_with_index do |file, fi|
        print "\u2502" #vertical line
        if file.nil?
          print "\u2022" #bullet point
        else
          print file.unicode # prints piece unicode
        end
      end
      puts "\u2502" #vertical line
    end
    puts "   A B C D E F G H"
    puts
  end

  #utility getter method to access the 8x8 array masked by Board class
  def [](pos)
    @board[pos[0]][pos[1]]
  end

  #utility setter method to set any "pos" in 8x8 array to "value"
  def []=(pos, value)
    @board[pos[0]][pos[1]] = value
  end

  #updates the status of the board
  def update_board
    #clear previous move_list from all pieces
    @board.each do |row|
      row.each do |col|
        col.move_list = [] if !col.nil?
      end
    end
    #clear previous state of @all_pieces
    @all_pieces = []
    #adds every piece obj to all_pieces instance variable
    @board.each do |row|
      row.each do |col|
        @all_pieces << col if !col.nil?
      end
    end
    #give each piece a copy of the board state
    #then allow generate_moves method to come up with a list of possible moves
    #based on that board state
    @all_pieces.each do |n|
      n.board = self
      n.generate_moves
    end
    #add this state to the board_history instance variable
    @board_history << @board
  end

  #method to find if a king is in check
  def in_check?(color)
    if color == "white"
      king = @all_pieces.select { |piece| piece.class == King && piece.color == "white"}[0]
    else
      king = @all_pieces.select { |piece| piece.class == King && piece.color == "black"}[0]
    end
    #iterate through every existing piece and check its move_list for a king in one of the move positions
    @all_pieces.each do |piece|
      #if piece is not a king and the opposing color
      if piece.class != King && piece.color != color
        return true if piece.move_list.include?(king.pos)
      end
    end
    return false
  end

  #method to determine checkmake
  def checkmate?(color)
    #if not in check, then can't be in checkmate!
    return false unless in_check?(color)
    color_pieces = @all_pieces.select { |piece| piece.color == color }
    #utilize Enumerable#all? method to determine if all pieces of "color"
    # have no more non-check moves. Returns true or false as a result.
    color_pieces.all? do |piece|
      piece.non_check_moves.empty?
    end
  end

  #method to determine stalemate
  def stalemate?(color)
    #if color has no more legal moves and is not in check
    return false if in_check?(color)
    color_pieces = @all_pieces.select { |piece| piece.color == color }
    color_pieces.all? do |piece|
      piece.non_check_moves.empty?
    end
    #conditionals for stalemate by repitition
    board_count = Hash.new(0) #hash to count board states
    #count every board state in history
    #if there's a board state being repeated 3 times, it's a stalemate
    @board_history.each do |state|
      board_count[state] += 1
    end
    #if there's a board state being repeated 3 times, it's a stalemate
    board_count.any? do |state, count|
      count >= 3
    end
  end

  #method to check board end conditions
  def end_conditions?(color)
    color_pieces = @all_pieces.select { |piece| piece.color == color }
    #keep this line for debugging purposes, prints current color's piece list and move list
    #color_pieces.each { |piece| puts "#{piece.class}:#{piece.non_check_moves.inspect}" }
    puts "CHECK!" if in_check?(color)
    return false if color_pieces.any? { |piece| !piece.non_check_moves.empty? }
    return checkmate?(color) || stalemate?(color)
  end

  def recent_piece
    return nil if @move_record.empty?
    #puts @move_record.last.inspect
    @board[@move_record.last.last[0]][@move_record.last.last[1]]
  end
end
