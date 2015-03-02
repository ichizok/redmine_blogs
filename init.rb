require 'redmine'
require 'acts-as-taggable-on'

require 'application_helper_global_patch'
require 'comment_patch'
require 'view_account_left_middle_hook'

# Patches to the Redmine core.
Rails.configuration.to_prepare do
  require_dependency 'comment'
  Comment.send(:include, RedmineBlogs::CommentPatch)

  require_dependency 'application_helper'
  ApplicationHelper.send(:include, RedmineBlogs::ApplicationHelperGlobalPatch)
end

Redmine::Plugin.register :redmine_blogs do
  name 'Redmine Blogs plugin'
  author 'A. Chaika, Kyanh, Eric Davis'
  description 'Redmine Blog plugin'
  version '0.6.0'
  requires_redmine :version_or_higher => '3.0.0'

  project_module :blogs do
    permission :manage_blogs, {:blogs => [:new, :create, :edit, :destroy]}, :require => :member
    permission :comment_blogs, {:blogs => [:add_comment, :destroy_comment]}
    permission :view_blogs, {:blogs => [:index, :preview, :show, :history]}
  end

  menu :project_menu, :blogs, {:controller => 'blogs', :action => 'index'},
       :caption => 'Blogs', :after => :news, :param => :project_id

  activity_provider :blogs

  Redmine::Search.register :blogs
end
