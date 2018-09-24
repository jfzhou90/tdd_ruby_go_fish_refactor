require('deck')

describe(CardDeck) do
  let(:deck) { CardDeck.new }

  describe('#initialize') do
    it('starts the deck with 52 cards') do
      expect(deck.deck_size).to be(52)
    end
  end

  describe('#Deal') do
    it('removes a card from the deck') do
      card = deck.deal
      expect(deck.deck_size).to be(51)
      expect(card).to be_an_instance_of(PlayingCard)
    end
  end

  describe('#shuffle') do
    it('shuffles the deck into a random order, may fail if shuffled is the same as non-shuffled') do
      deck.shuffle
      card = deck.deal
      card2 = PlayingCard.new
      expect(card == card2).to be(false)
    end
  end
end
