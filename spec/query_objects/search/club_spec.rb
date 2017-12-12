describe Search::Club do
  before do
    allow(Elasticsearch::Query::Club)
      .to receive(:call)
      .with(phrase: phrase, limit: ids_limit, locale: locale)
      .and_return results
  end
  subject do
    Search::Club.call(
      scope: scope,
      phrase: phrase,
      ids_limit: ids_limit,
      locale: locale
    )
  end

  describe '#call' do
    let(:scope) { Club.all }
    let(:phrase) { 'zxct' }
    let(:ids_limit) { 2 }
    let(:locale) { 'ru' }
    let(:results) { { club_1.id => 0.123123 } }

    let!(:club_1) { create :club, name: 'test' }
    let!(:club_2) { create :club, name: 'test zxct' }

    it { is_expected.to eq [club_1] }
  end
end

