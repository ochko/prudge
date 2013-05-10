ThinkingSphinx::Index.define :post, :with => :active_record, :delta => true do
  indexes :title
  indexes :body

  set_property :field_weights => { 
    :title => 7,
    :body => 4
  }
end
