require('rspec')
require('playing_card')
require('player')

describe(Player) do
  let(:player) { Player.new(name:'Joey') }
  let(:card) { PlayingCard.new }
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

    it(" ")
  end

  describe('#cards_left') do
    # it('shows how many card left.') do
    #   player.add_cards(card)
      # expect(player.)
  end
end
