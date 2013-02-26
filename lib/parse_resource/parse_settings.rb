class ParseSettings
  def self.method_missing(method_name, *args)
    @@settings ||= (YAML::load(File.read("#{Rails.root}/config/parse_resource.yml"))[Rails.env] || {}).with_indifferent_access
    if /\A(?<setter_key>\w+)=\z/ =~ method_name.to_s
      define_singleton_method(method_name) {|v| @@settings[setter_key] = v}
      send method_name, args[0]
    elsif /\A(?<key>\w+)\z/ =~ method_name.to_s
      define_singleton_method(method_name) {@@settings[key]}
      send method_name
    end
  end
end
