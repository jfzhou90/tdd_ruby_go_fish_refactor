require('rspec')
require('playing_card')

describe(PlayingCard) do
  let(:card1) { PlayingCard.new }
  let(:card2) { PlayingCard.new(rank: 'A', suit: 'Clubs') }
  let(:card3) { PlayingCard.new(rank: 2, suit: 'Hearts') }
  let(:card4) { PlayingCard.new(rank: 2, suit: 'Hearts') }

  describe('#initialize') do
    it('create a card with default rank and suit if no arguments input') do
      expect(card1.rank).to eq('A')
      expect(card1.suit).to eq('Spades')
    end

    it('take in arguments to create specific rank and suit') do
      expect(card3.rank).to eq(2)
      expect(card3.suit).to eq('Hearts')
    end
  end

  describe('#to_s') do
    it('read the card in human readable way') do
      expect(card1.to_s).to eq('A of Spades')
      expect(card2.to_s).to eq('A of Clubs')
      expect(card3.to_s).to eq('2 of Hearts')
    end
  end

  describe('#==') do
    it('compare cards to see if they are equal rank and suit') do
      expect(card1 == card2).to be(false)
      expect(card3 == card4).to be(true)
    end
  end

  describe('#rank_equal') do
    it('compare cards to see if the rank matches') do
      expect(card1.rank_equal(card3)).to be(false)
      expect(card1.rank_equal(card2)).to be(true)
    end
  end
end
