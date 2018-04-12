# frozen_string_literal: true
# Source: https://github.com/elastic/apm-agent-ruby/blob/master/lib/elastic_apm/middleware.rb

module ElasticApmRailsMiddleware
  class Middleware
    def initialize(app)
      @app = app
    end

    # rubocop:disable Metrics/MethodLength
    def call(env)
      begin
        request = ActionDispatch::Request.new(env)
        route_name = env['REQUEST_PATH']

        Rails.application.routes.router.recognize(request) do |route, params|
          route_name = ActionDispatch::Routing::RouteWrapper.new(route).path
        end

        transaction_name = [request.request_method, route_name].join(' ')

        transaction = ElasticAPM.transaction transaction_name, 'app',
          context: ElasticAPM.build_context(env)

        resp = @app.call env

        transaction.submit(resp[0], headers: resp[1]) if transaction
      rescue InternalError
        raise # Don't report ElasticAPM errors
      rescue ::Exception => e
        ElasticAPM.report(e, handled: false)
        transaction.submit(500) if transaction
        raise
      ensure
        transaction.release if transaction
      end

      resp
    end
    # rubocop:enable Metrics/MethodLength
  end
end
