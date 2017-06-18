Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
	root to: 'splash#index'
	
	# トラック一覧
	get 'tracks', to: 'tracks#index'
	
	# アーティスト・アーティスト検索。あとでshowもつける
	resources :artists,only: [:index] do
		collection do
			get :search
		end
	end
	
	# TODO お気に入り機能やるなら
	# resources :favorites, only: [:create, :destroy]
end
