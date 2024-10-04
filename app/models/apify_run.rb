class ApifyRun < ApplicationRecord
  enum state: { waiting: 0, finished: 1 }

  belongs_to :channel
end
