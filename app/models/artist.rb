class Artist < ApplicationRecord
	validates :name, presence: true, length: { maximum: 255 }
	validates :img_s, presence: true, length: { maximum: 255 }
	validates :img_l, presence: true, length: { maximum: 255 }
	validates :summary, presence: true, length: { maximum: 255 }
	validates :similar, presence: true, length: { maximum: 255 }
	validates :topTracks, presence: true, length: { maximum: 255 }
end
