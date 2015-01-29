module Hob
  class Web < Sinatra::Base

    # List apps
    get '/apps.?:format?' do
      apps = World.db[:apps].all

      respond_to(params[:format], :app_list, apps: apps)
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
      ruby = Lang::Ruby.new

      erb(:app_create, locals: { ruby_versions: ruby.versions })
    end

    post '/apps/.?:format?' do
      app = ::Hob::App.new(params[:name], params)
      created = ::Hob::App::Create.new(app).call

      if params[:format] == 'json'
        JSON.dump(created)
      else
        redirect to("/apps/#{app.name}")
      end
    end

    # Show app
    get '/apps/:name.?:format?' do
      app = App.new(params[:name])

      respond_to(params[:format], :app_show, { app: app })
    end

    # Deploy app
    put '/apps/:name.?:format?' do
      app = App.new(params[:name])
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

    def respond_to(format, template, locals)
      if format == 'json'
        JSON.dump(locals)
      else
        erb(template, locals: locals)
      end
    end

  end
end
