require_relative('./playing_card')

class CardDeck
  def initialize
    create_deck_of_cards
  end

  def deal
    cards_left.pop
  end

  def shuffle
    cards_left.shuffle!
  end

  def deck_size
    cards_left.length
  end

  def empty?
    cards_left.empty?
  end

  private

  attr_reader :cards_left

  def create_deck_of_cards
    suits = %w[Clubs Diamonds Hearts Spades]
    ranks = %w[2 3 4 5 6 7 8 9 10 Jack Queen King Ace]
    @cards_left = ranks.map do |rank|
      suits.map do |suit|
        PlayingCard.new(rank: rank, suit: suit)
      end
    end.flatten
  end
end

# this is for testing.
class TestDeck < CardDeck
  def initialize
    super()
  end

  def shuffle
    # do nothing
  end

  def shuffle_test
    cards_left.shuffle!
  end

  private

  attr_reader :cards_left

  def create_deck_of_cards
    suits = %w[Clubs Diamonds Hearts Spades]
    ranks = %w[2 3 4 King Ace]
    @cards_left = ranks.map do |rank|
      suits.map do |suit|
        PlayingCard.new(rank: rank, suit: suit)
      end
    end.flatten
  end
end
