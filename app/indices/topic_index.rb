ThinkingSphinx::Index.define :topic, :with => :active_record do
  indexes :title
  indexes :description

  set_property :field_weights => { 
    :title => 7,
    :description => 4
  }

  set_property :delta => true
end
