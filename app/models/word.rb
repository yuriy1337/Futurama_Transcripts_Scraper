class Word < ActiveRecord::Base
  has_many :counts
  has_many :speakers, :through => :counts
  has_many :episodes, :through => :counts
end
