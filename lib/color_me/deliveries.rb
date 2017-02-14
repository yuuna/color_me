require "color_me/single_resource"

module ColorMe
  module Deliveries
    extend SingleResource

    def endpoint
      '/v1/deliveries.json'
    end

    extend self
  end
end
