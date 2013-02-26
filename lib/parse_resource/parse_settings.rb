class ParseSettings < Settingslogic
  source "#{Rails.root}/config/parse_resource.yml"
  namespace Rails.env
end
