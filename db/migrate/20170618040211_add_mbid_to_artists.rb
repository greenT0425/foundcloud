class AddMbidToArtists < ActiveRecord::Migration[5.0]
  def change
    add_column :artists, :mbid, :string
  end
end
