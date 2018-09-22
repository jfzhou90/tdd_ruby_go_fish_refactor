class PlayingCard
  attr_reader :rank, :suit
  def initialize(rank: 'A', suit: 'Spades')
    @rank = rank
    @suit = suit
  end

  def to_s
    "#{rank} of #{suit}"
  end

  def ==(other)
    rank == other.rank && suit == other.suit
  end

  def rank_equal(other)
    rank == other.rank
  end
end
