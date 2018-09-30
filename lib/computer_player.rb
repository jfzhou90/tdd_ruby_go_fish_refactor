require('./lib/player')

class ComputerPlayer < Player
  attr_reader :name
  def initialize(name)
    super(name: name)
  end

  def pick_random_rank
    ranks[rand(0...ranks.size)]
  end
end
