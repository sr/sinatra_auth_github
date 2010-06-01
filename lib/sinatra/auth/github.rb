module Sinatra
  module Auth
    module Github
      class BadAuthentication < Sinatra::Base
        get '/unauthenticated' do
          status 403
          "Unable to authenticate, sorry bud."
        end
      end

      module Helpers
        def warden
          env['warden']
        end

        def authenticate!(*args)
          warden.authenticate!(*args)
        end

        def authenticated?(*args)
          warden.authenticated?(*args)
        end

        def logout!
          warden.logout
        end

        def github_user
          warden.user
        end
      end

      def self.registered(app)
        app.use Warden::Manager do |manager|
          manager.default_strategies :github

          manager.failure_app           = app.github_options[:failure_app] || BadAuthentication

          manager[:github_secret]       = app.github_options[:secret]
          manager[:github_client_id]    = app.github_options[:client_id]
          manager[:github_callback_url] = app.github_options[:callback_url] || '/auth/github/callback'
        end

        app.helpers Helpers

        app.get '/auth/github/callback' do
          authenticate!
          redirect "/"
        end
      end
    end
  end
end