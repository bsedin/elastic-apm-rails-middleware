# frozen_string_literal: true

module ElasticApmRailsMiddleware
  # @api private
  class Railtie < Rails::Railtie
    initializer 'elastic_apm_rails_middleware.initialize' do |app|
      app.middleware.swap ::ElasticAPM::Middleware, ::ElasticApmRailsMiddleware::Middleware
    end
  end
end
