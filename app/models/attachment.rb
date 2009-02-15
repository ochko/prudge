class Attachment < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true
  has_attachment  :storage => :file_system,
                  :max_size => 10.megabytes,
                  :path_prefix => 'attachments/'
  validates_as_attachment
end
