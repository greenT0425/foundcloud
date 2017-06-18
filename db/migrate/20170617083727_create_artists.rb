class CreateArtists < ActiveRecord::Migration[5.0]
  def change
    create_table :artists do |t|
      t.string :name
      t.string :img_s
      t.string :img_l
      t.string :summary
      t.string :similar
      t.string :topTracks

      t.timestamps
    end
  end
end
