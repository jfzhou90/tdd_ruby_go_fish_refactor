class Player
  attr_reader :name, :hand

  def initialize(name: 'Unknown Player')
    @name = name
    @hand = []
    @sets = []
  end

  def add_cards(cards)
    cards.is_a?(Array) ? hand.concat(cards) : hand.push(cards)
    sort_cards
  end

  def cards_left
    hand.count
  end

  def empty?
    cards_left.zero?
  end

  def any_rank?(rank)
    ranks.any? { |hand_rank| hand_rank.casecmp(rank).zero? }
  end

  def give(rank)
    cards = hand.select { |card| rank.casecmp(card.rank).zero? }
    hand.reject! { |card| rank.casecmp(card.rank).zero? }
    cards
  end

  def check_complete
    ranks.each { |rank| make_a_book(rank) if count(rank) == 4 }
  end

  def points
    sets.map(&:rank).uniq.count
  end

  private

  attr_reader :sets

  def ranks
    hand.map(&:rank).uniq
  end

  def make_a_book(rank)
    cards = give(rank)
    sets.concat(cards)
  end

  def count(rank)
    hand.count { |card| card.rank == rank }
  end

  def sort_cards
    hand.sort! { |card1, card2| card1.to_s <=> card2.to_s } if cards_left > 1
  end
end
