class Channel < ApplicationRecord
  UNCHECKED_STATE = "unchecked"
  CHECKING_STATE = "checking"
  CHECKED_STATE = "checked"
  CHECK_FAILED_STATE = "check_failed"

  belongs_to :user
  has_many :videos
  has_one_attached :avatar
end
