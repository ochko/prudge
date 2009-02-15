class Banner < ActiveRecord::Base
  has_attachment  :storage => :file_system,
                  :content_type => :image,
                  :max_size => 1.megabytes,
                  :resize_to => '160x',
                  :thumbnails => { :thumb => '100x', :tiny => '40x' },
                                   :processor => :MiniMagick
  validates_as_attachment
end
