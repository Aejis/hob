module Hob
  class Web < Sinatra::Base
    use Rack::MethodOverride

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

      respond_or_redirect(params[:format], "/apps/#{app.name}", created)
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

    # Get env variables for app
    get '/apps/:name/envs.?:format?' do
      app = App.new(params[:name])

      respond_to(params[:format], :app_env_show, { name: app.name, env: app.env })
    end

    # Create env variable
    post '/apps/:name/envs.?:format?' do
      app = App.new(params[:name])
      app.env[params[:key]] = params[:value]

      respond_or_redirect(params[:format], "/apps/#{params[:name]}/envs", { key: params[:key], value: params[:value] })
    end

    patch '/apps/:name/envs.?:format?' do
      app = App.new(params[:name])
      app.env.update(params[:oldkey], params[:key], params[:value])

      respond_or_redirect(params[:format], "/apps/#{params[:name]}/envs", { key: params[:key], value: params[:value] })
    end

    delete '/apps/:name/envs.?:format?' do
      app = App.new(params[:name])
      deleted = app.env.delete(params[:key])

      respond_or_redirect(params[:format], "/apps/#{params[:name]}/envs", deleted)
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

    def respond_or_redirect(format, path, data)
      if format == 'json'
        JSON.dump(data)
      else
        redirect to(path)
      end
    end

  end
end
