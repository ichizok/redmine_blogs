# copied from /app/models/news.rb

class Blog < ActiveRecord::Base
  unloadable

  belongs_to :project
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  has_many :comments,
    lambda { order(:created_on) },
    :as => :commented, :dependent => :delete_all

  acts_as_taggable
  acts_as_attachable

  validates_presence_of :title, :description
  validates_length_of :title, :maximum => 255
  validates_length_of :summary, :maximum => 255

  attr_accessible :summary, :description, :title, :tag_list

  acts_as_activity_provider :type => 'blogs',
                            :scope => preload(:author, :project),
                            :author_key => :author_id

  acts_as_event :type => 'blog-post',
                :url => Proc.new {|o| {:controller => 'blogs', :action => 'show', :id => o.id}}

  acts_as_searchable :columns => ['title', 'summary', "#{table_name}.description"],
                     # sort by id so that limited eager loading doesn't break with postgresql
                     #:order_column => :id,
                     :preload => [:project]

  scope :visible, lambda {|*args|
    joins(:author, :project).
    where(Project.allowed_to_condition(args.shift || User.current, :view_blogs, *args))
  }

  # returns latest blogs for projects visible by user
  def self.latest(user = User.current, count = 5)
    Blog.includes(:author, :project).visible(user).limit(count).order(:created_on => :desc)
  end

  def editable_by?(user = User.current)
    user == author && user.allowed_to?(:manage_blogs, project, :global => true)
  end

  def attachments_deletable?(user = User.current)
    true
  end

  def attachments_visible?(user = User.current)
    true
  end

  def short_description()
    desc, more = description.split(/\{\{more\}\}/mi)
    desc
  end

  def has_more?()
    desc, more = description.split(/\{\{more\}\}/mi)
    more
  end

  def full_description()
    description.gsub(/\{\{more\}\}/mi,"")
  end

  if Rails.env.test?
    generator_for :title, :method => :next_title
    generator_for :description, :method => :next_description
    generator_for :summary, :method => :next_summary

    def self.next_title
      @last_title ||= 'Title 0000'
      @last_title.succ!
      @last_title
    end

    def self.next_description
      @last_description ||= 'Description 0000'
      @last_description.succ!
      @last_description
    end

    def self.next_summary
      @last_summary ||= 'Summary 0000'
      @last_summary.succ!
      @last_summary
    end

  end

end
