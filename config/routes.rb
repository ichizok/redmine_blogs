RedmineApp::Application.routes.draw do
  controller :blogs do
    match 'projects/:project_id/blogs/new', :to => :new
    match 'projects/:project_id/blogs(.:format)', :to => :index
    #match 'blogs/users/:id', :to => :show_by_user
    #match 'blogs/tags/:id', :to => :show_by_tag
    match 'blogs/get_tag_list', :to => :get_tag_list
    match 'blogs/preview', :to => :preview
    match 'blogs/:id', :to => :show
    match 'blogs/:id/:action', :via => [:post, :put]
    match 'blogs/:id/comments/:comment_id', :to => :destroy_comment, :via => [:delete]
  end
end
