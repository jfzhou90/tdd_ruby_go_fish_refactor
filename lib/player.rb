class Player
  attr_reader :name, :hand, :auto

  def initialize(name: 'Unknown Player')
    @name = name
    @hand = []
    @sets = []
    @auto = false
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
    old_points = points
    ranks.each { |rank| make_a_book(rank) if count(rank) == 4 }
    true if points != old_points
  end

  def points
    sets.map(&:rank).uniq.count
  end

  def pick_random_rank
    ranks[rand(0...ranks.size)]
  end

  def toggle_autoplay
    self.auto = !auto
  end

  private

  attr_reader :sets
  attr_writer :auto

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
