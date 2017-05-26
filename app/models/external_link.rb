class ExternalLink < ApplicationRecord
  belongs_to :entry, polymorphic: true, touch: true
  validates :entry, :source, :kind, :url, presence: true

  enumerize :kind,
    in: Types::ExternalLink::Kind.values,
    predicates: { prefix: true }

  enumerize :source,
    in: Types::ExternalLink::Source.values,
    predicates: { prefix: true }

  KINDS = {
    anime: Types::ExternalLink::Kind.values - %i[
      ruranobe readmanga
    ],
    manga: Types::ExternalLink::Kind.values - %i[
      world_art kage_project anime_db ruranobe
    ],
    ranobe: Types::ExternalLink::Kind.values - %i[
      world_art kage_project anime_db readmanga
    ]
  }

  WIKIPEDIA_LABELS = {
    ru: 'Википедия',
    en: 'Wikipedia',
    ja: 'ウィキペディア',
    zh: '维基百科'
  }

  def label
    if kind_wikipedia? && url =~ %r{/(?<lang>ru|en|ja|zh)\.wikipedia\.org/}
      WIKIPEDIA_LABELS[$LAST_MATCH_INFO[:lang].to_sym] || kind_text
    else
      kind_text
    end
  end
end
