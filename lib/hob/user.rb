require 'bcrypt'

module Hob
  class User
    class << self
      def authenticate(login, password)
        params = World.db[:users][login: login] or return
        u = new(params)
        u.admin! if params[:admin] == true
        u if u.password == password
      end

      def fetch(id)
        params = World.db[:users][id: id]
        if params
          user = new(params)
          user.admin! if params[:admin] == true
          user
        end
      end
    end

    def id
      @params[:id]
    end

    def login
      @params[:login]
    end

    def name
      @params[:name]
    end

    def github_name
      @params[:github_name]
    end

    def github_token
      @params[:github_token]
    end

    def password
      ::BCrypt::Password.new(@params[:password])
    end

    def password=(str)
      @params[:password] = ::BCrypt::Password.create(str)
    end

    def approve!
      @params[:approved] = true
    end

    def approved?
      !!@params[:approved]
    end

    def admin?
      @admin
    end

    def admin!
      @admin = true
    end

    def persist!
      @params[:admin] = true if @admin

      if persisted?
        World.db[:users].where(id: id).update(@params)
      else
        self.password = @params[:password]
        id = World.db[:users].insert(@params)
        @params[:id] = id
        @params
      end
    end

    def persisted?
      !!@params[:id]
    end

  private

    def initialize(params)
      params.delete(:admin)

      @params = params
      @admin  = false
    end

  end
end
