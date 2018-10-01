require('rspec')
require('playing_card')
require('player')

describe(Player) do
  let(:player) { Player.new(name: 'Joey') }
  let(:card) { PlayingCard.new }
  let(:card2) { PlayingCard.new(rank: 'King', suit: 'Spades') }
  let(:array_of_cards) { [PlayingCard.new, PlayingCard.new, PlayingCard.new, PlayingCard.new] }

  describe('#initialize') do
    it('creates a player with a name.') do
      expect(player.name).to eq('Joey')
    end
  end

  describe('#add_cards') do
    it("adds a card to player's hand") do
      player.add_cards(card)
      expect(player.send(:hand).count).to eq(1)
      expect(player.send(:hand)[0]).to be_an_instance_of(PlayingCard)
    end

    it("adds an array of cards to player's hand") do
      player.add_cards(array_of_cards)
      expect(player.send(:hand).count).to eq(4)
    end

    it('sorts the hand when card being added') do
      player.add_cards(card2)
      player.add_cards(card)
      expect(player.send(:ranks)).to eq(%w[Ace King])
    end
  end

  describe('#cards_left') do
    it('shows how many card left.') do
      player.add_cards(array_of_cards)
      expect(player.cards_left).to eq(4)
      player.add_cards(card)
      expect(player.cards_left).to eq(5)
    end
  end

  describe('#empty?') do
    it('returns true if hand is empty, and false if not') do
      expect(player.empty?).to be(true)
      player.add_cards(card)
      expect(player.empty?).to be(false)
    end
  end

  describe('#ranks') do
    it('returns the array of uniq ranks that player have') do
      player.add_cards(array_of_cards)
      player.add_cards(card)
      player.add_cards(card2)
      expect(player.send(:ranks).count).to be(2)
      expect(player.send(:ranks)).to eq(%w[Ace King])
    end
  end

  describe('#any_rank?') do
    it('returns true if player owns the rank, false if not') do
      expect(player.any_rank?('Ace')).to be(false)
      player.add_cards(card)
      expect(player.any_rank?('Ace')).to be(true)
    end

    it('player input can be case insensitive') do
      expect(player.any_rank?('ace')).to be(false)
      player.add_cards(card)
      expect(player.any_rank?('ace')).to be(true)
    end
  end

  describe('#give') do
    it('return requested cards and remove them from player') do
      player.add_cards(card)
      player.add_cards(card2)
      expect(player.give('Ace')[0].rank).to eq('Ace')
      expect(player.cards_left).to eq(1)
      expect(player.send(:hand)[0].rank).to eq('King')
    end
  end

  describe('#count') do
    it('counts the number of the same rank') do
      player.add_cards(card)
      expect(player.send(:count, 'Ace')).to be(1)
      player.add_cards(array_of_cards)
      expect(player.send(:count, 'Ace')).to be(5)
    end
  end

  describe('#make_a_book') do
    it('removes cards of the same rank and make a book') do
      player.add_cards(array_of_cards)
      player.send(:make_a_book, 'Ace')
      expect(player.cards_left).to be(0)
      expect(player.send(:sets).count).to be(4)
    end
  end

  describe('#check_complete') do
    it('removes cards of the same rank only when there is a complete set') do
      player.add_cards(card2)
      player.add_cards(array_of_cards)
      player.check_complete
      expect(player.cards_left).to be(1)
      expect(player.send(:sets).count). to be(4)
    end
  end

  describe('#points') do
    it('adds a point when a set is completed') do
      expect(player.points).to be(0)
      player.add_cards(array_of_cards)
      player.check_complete
      expect(player.points).to be(1)
    end
  end

  describe('#toggle_autoplay') do
    it('toggles auto status on the player') do
      expect(player.auto).to be(false)
      player.toggle_autoplay
      expect(player.auto).to be(true)
    end
  end
end
