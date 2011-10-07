class Count < ActiveRecord::Base
  belongs_to :episode
  belongs_to :word
  belongs_to :speaker
end
