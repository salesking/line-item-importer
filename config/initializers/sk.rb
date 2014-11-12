require 'sk_api_schema'
require 'sk_sdk/base'
require 'sk_sdk/oauth'
# Tiny helper class for talking to SalesKing
# - Setup local Sk:: classes for remote objects. contact, address,..
# - construct writable fields
class Sk
  # setup oAuth app info, local classes
  conf = YAML.load_file(Rails.root.join('config', 'salesking_app.yml'))
  App  = SK::SDK::Oauth.new(conf[Rails.env])

  class Contact < SK::SDK::Base; end
  class Address < SK::SDK::Base; end
  class Invoice < SK::SDK::Base; end
  class Order < SK::SDK::Base; end
  class CreditNote < SK::SDK::Base; end
  class Estimate < SK::SDK::Base; end
  class Item < SK::SDK::Base; end
  class LineItem < SK::SDK::Base; end

  # init SalesKing classes and set connection oAuth token
  def self.init(site, token)
    SK::SDK::Base.set_connection(site: site, token: token)
  end

  # reset SalesKing class connections so on user does not see the oAuth token
  # from another
  def self.reset_connection
    SK::SDK::Base.site = nil
    SK::SDK::Base.headers['Authorization'] = nil
  end

  # read json-schema
  def self.read_schema(kind)
    SK::Api::Schema.read(kind, '1.0')
  end
end

