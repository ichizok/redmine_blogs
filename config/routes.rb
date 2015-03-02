RedmineApp::Application.routes.draw do
  resources :projects do
    resources :blogs, :only => [:new, :create, :index]
  end
  resources :blogs, :only => [:show, :destroy] do
    collection do
      get 'get_tag_list'
      match 'preview', :via => [:post, :put, :patch]
    end
    member do
      match 'edit', :via => [:post, :put, :patch]
      post 'add_comment'
      delete 'comments/:comment_id', :to => 'blogs#destroy_comment'
    end
  end
end
