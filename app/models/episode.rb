class Episode < ActiveRecord::Base
  has_many :counts
  has_many :words, :through => :counts
end
