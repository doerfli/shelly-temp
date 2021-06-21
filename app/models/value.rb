class Value < ApplicationRecord
  belongs_to :device
  belongs_to :type
end
