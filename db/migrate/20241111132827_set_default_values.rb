class SetDefaultValues < ActiveRecord::Migration[7.0]
  def change
    Hack.where(is_hack: nil).update_all(is_hack: false)
    HackValidation.where(status: nil).update_all(status: false)

    change_column_default :hacks, :is_hack, false
    change_column_default :hack_validations, :status, false
  end
end
