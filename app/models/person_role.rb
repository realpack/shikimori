class PersonRole < ActiveRecord::Base
  belongs_to :anime
  belongs_to :manga
  belongs_to :character
  belongs_to :person

  scope :main, -> { where "role = 'Main' and character_id != 0" }
  scope :people, -> { where("person_id != 0 and people.name != ''").includes(:person) }
  scope :directors, -> { people.where "role like '%Director%' or role like '%Original Creator%' or role like '%Story & Art%' or role like '%Story%' or role like '%Art%'" }
end
