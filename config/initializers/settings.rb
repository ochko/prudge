class Settings
  metaclass = class << self; self; end
  
  YAML.load_file(Rails.root.join 'config', 'settings.yml').each do |k,v|
    metaclass.send(:define_method, k) do
      v
    end
  end
end


