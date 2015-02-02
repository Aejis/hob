require 'warden'

module Hob
  module Warden

    module Helpers
      def warden
        env['warden']
      end

      def current_user
        warden.user
      end

      def authorize!(*args)
        warden.authenticate!(*args)

        halt([401, 'Unauthorized User']) unless current_user && current_user.approved?
      end

      def authorize_admin!(*args)
        warden.authenticate!(*args)

        halt([401, 'Unauthorized User']) unless current_user && current_user.admin?
      end
    end

    class Password < ::Warden::Strategies::Base
      def valid?
        params['username'] && params['password']
      end

      def authenticate!
        u = User.authenticate(params['username'], params['password'])
        u.nil? ? fail!('Could not log in') : success!(u)
      end
    end
  end
end

Warden::Strategies.add(:password, Hob::Warden::Password)
