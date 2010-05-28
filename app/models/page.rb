class Page < ActiveRecord::Base

  attr_accessible :title, :body_raw, :published_at, :is_active, :permalink, :meta_keywords, :meta_description
  
  before_validation :format_markup
  #before_validation :generate_permalink
  before_validation :published
   
  validates_presence_of :title, :message => 'required'
  validates_uniqueness_of :permalink 
  
  make_permalink :with => :title
  
  default_scope :order => 'published_at DESC'
  named_scope :publish, :conditions => [ 'published_at < ? and is_active = ?', Time.zone.now, 1]
  
  def format_markup
    if not self.body.nil?
      self.body = RedCloth.new(self.body_raw,[:sanitize_html, :filter_html]).to_html
    end
    
    #~ if self.excerpt.blank?
      #~ self.excerpt = self.body.gsub(/\<[^\>]+\>/, '')[0...50] + "..."
    #~ else
      #~ self.excerpt = self.excerpt.gsub(/\<[^\>]+\>/, '')
    #~ end
    
  end
  
  def generate_permalink
    self.permalink = self.title.dup if self.permalink.blank?
    self.permalink.linkify!
  end

  def link
    ensure_slash_prefix permalink
  end
  
  def published
    #self.published_at ||= Time.now unless self.is_active == 0
    if self.is_active == 0
      if !self.published_at.blank?
          self.published_at = nil
      end
    else
      if self.published_at.blank?
          self.published_at = Time.now
      end
    end
  end
  
  def month
    published_at.strftime('%B %Y')
  end
  
  #def to_param
  #  "#{id}-#{permalink}"
  #end
  
  def to_param
    return permalink unless permalink.blank?
    title.to_url
  end
  
  # use deleted? rather than checking the attribute directly. this
  # allows extensions to override deleted? if they want to provide
  # their own definition.
  #def deleted?
  #  deleted_at
  #end
  
private

  def ensure_slash_prefix(str)
    str.index('/') == 0 ? str : '/' + str
  end
end