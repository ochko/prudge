class Photo < ActiveRecord::Base
  belongs_to :user
  has_attachment  :storage => :file_system,
                  :content_type => :image,
                  :max_size => 1.megabytes,
                  :resize_to => '240x320>',
                  :thumbnails => { :thumb => '90x120>', :tiny => '45x60>' },
                                   :processor => :MiniMagick
  validates_as_attachment
end
