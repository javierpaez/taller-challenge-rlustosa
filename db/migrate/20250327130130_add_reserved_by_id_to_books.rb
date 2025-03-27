class AddReservedByIdToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :reserved_by_email, :string, default: nil
  end
end
