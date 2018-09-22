class Player
  attr_reader :name

  def initialize(name: 'Unknown Player')
    @name = name
    @hand = []
    @sets = []
  end

  def add_cards(cards)
    cards.is_a?(Array) ? hand.concat(cards) : hand.push(cards)
  end

  def cards_left
    hand.count
  end

  private

  attr_reader :hand
end
