module Hob
  class Web < Sinatra::Base

    # List apps
    get '/' do
      apps = DB[:apps].all

      respond_to(params[:format], :list, apps: apps)
    end

    # Create
    #
    # Params:
    # - name
    # - repo
    # - branch
    # - ruby_version
    # - prepare_commands
    # - run_commands
    #
    get '/apps/create' do
      erb(:create)
    end

    post '/apps/.?:format?' do
      created = DB[:apps].insert(restrict(params))

      respond_to(params[:format], :created, created: created)
    end

    # Show app
    get '/apps/:name.?:format?' do
      builds = DB[:builds].where(app_name: params[:name])

      respond_to(params[:format], :show, { builds: builds })
    end

    # Restart app
    get '/apps/:name/restart.?:format?' do

    end

    # Stop app
    get '/apps/:name/stop.?:format?' do

    end

    # Start app
    get '/apps/:name/start.?:format?' do

    end

    # Show build
    get '/apps/:name/build/:id.?:format?' do

    end

  private

    ALLOWED_FIELDS = Set[:name, :repo, :branch, :ruby_version, :prepare_commands, :run_commands].freeze

    def restrict(params)
      params.keep_if { |k, _| ALLOWED_FIELDS.include?(k) }
    end

    def respond_to(format, template, locals)
      if format == 'json'
        JSON.dump(locals)
      else
        erb(template, locals)
      end
    end

  end
end
