require 'mustermann'
require 'hob/warden'

module Hob
  class Web < Sinatra::Base
    use Rack::MethodOverride

    register Mustermann

    enable :sessions

    enable :static
    set :public_folder, File.join(File.dirname(__FILE__), 'assets')

    use ::Warden::Manager do |manager|
      manager.default_strategies(:password)
      manager.failure_app = ::Hob::Web

      manager.serialize_into_session { |u| u.id }
      manager.serialize_from_session { |id| User.fetch(id) }
    end

    helpers Warden::Helpers

    get '/login' do
      erb(:login, layout: :base)
    end

    get '/register' do
      erb(:register, layout: :base)
    end

    get '/logout' do
      warden.logout

      redirect to('/login')
    end

    post '/login' do
      warden.authenticate!

      redirect to('/')
    end

    post '/register' do
      user = User.new(@params)
      user.persist!

      redirect to('/login')
    end

    get '/unauthenticated' do
      redirect to('/login')
    end
    post '/unauthenticated' do
      redirect to('/login')
    end

    get '/' do
      authorize!

      actions = World.db[:actions].order(Sequel.desc(:finished_at)).limit(10)
      apps = World.db[:apps].map { |app| App.new(app[:name], app) }

      erb(:index, locals: { actions: actions, apps: apps })
    end

    get '/users/?(.:format)?' do
      authorize_admin!

      users = World.db[:users].all

      respond_to(params[:format], :user_list, { users: users })
    end

    post '/users/:id/approve/?(.:format)?' do
      authorize_admin!

      user = User.fetch(id)

      user.approve!
      user.persist!

      redirect to('/users')
    end

    # List apps
    get '/apps/?(.:format)?' do
      authorize!
      apps = World.db[:apps].map { |app| App.new(app[:name], app) }

      respond_to(params[:format], :app_list, apps: apps)
    end

    # Show action log
    # TODO: decide to move route under /actions
    get '/apps/:name/actions/:id/?(.:format)?' do
      authorize!

      action = World.db[:actions][id: params[:id]]
      app = App.new(action[:app_name])
      logs = World.db[:action_logs].where(action_id: action[:id])

      respond_to(params[:format], :app_action_show, { app: app, action: action, logs: logs })
    end

    get '/apps/create' do
      authorize!

      ruby = Lang::Ruby.new
      app = App.new('')

      erb(:app_create, locals: { app: app, ruby_versions: ruby.versions, errors: {} })
    end

    # Show app
    get '/apps/:name/?(.:format)?' do
      authorize!

      app = App.new(params[:name])
      log = World.db[:actions].where(app_name: app.name).order(Sequel.desc(:finished_at)).limit(10)

      respond_to(params[:format], :app_show, { app: app, log: log })
    end

    get '/apps/:name/edit' do
      authorize!

      app = ::Hob::App.new(params[:name])
      ruby = Lang::Ruby.new

      erb(:app_edit, locals: { app: app, ruby_versions: ruby.versions })
    end

    # Create
    #
    # Params:
    # - name
    # - repo
    # - branch
    # - ruby_version
    # - prepare_commands
    # - test_commands
    # - start_commands
    # - stop_commands
    #
    post '/apps/?(.:format)?' do
      authorize!

      app = ::Hob::App.new(params[:name], params)

      if app.valid?
        created = ::Hob::App::Create.new(app).call

        respond_or_redirect(params[:format], "/apps/#{app.name}/envs", created)
      else
        ruby = Lang::Ruby.new

        erb(:app_create, locals: { app: app, ruby_versions: ruby.versions, errors: app.errors })
      end
    end

    patch '/apps/:app_name/?(.:format)?' do
      authorize!

      app = App.new(params[:app_name], params)
      update = App::Update.new(app)
      update.call

      respond_or_redirect(params[:format], "/apps/#{app.name}", update)
    end

    # Deploy app
    put '/apps/:name/?(.:format)?' do
      authorize!

      app = App.new(params[:name])

      action = App::Action.new(app, current_user)
      action.deploy

      redirect to("/apps/#{app.name}/actions/#{action.id}")
    end

    # Get env variables for app
    get '/apps/:name/envs/?(.:format)?' do
      authorize!

      app = App.new(params[:name])

      respond_to(params[:format], :app_env_show, { environment: app.env })
    end

    # Create env variable
    post '/apps/:name/envs/?(.:format)?' do
      authorize!

      app = App.new(params[:name])
      app.env[params[:key]] = params[:value]

      respond_or_redirect(params[:format], "/apps/#{params[:name]}/envs", { key: params[:key], value: params[:value] })
    end

    patch '/apps/:name/envs/?(.:format)?' do
      authorize!

      app = App.new(params[:name])
      app.env.update(params[:oldkey], params[:key], params[:value])

      respond_or_redirect(params[:format], "/apps/#{params[:name]}/envs", { key: params[:key], value: params[:value] })
    end

    delete '/apps/:name/envs/?(.:format)?' do
      authorize!

      app = App.new(params[:name])
      deleted = app.env.delete(params[:key])

      respond_or_redirect(params[:format], "/apps/#{params[:name]}/envs", deleted)
    end

    # Restart app
    get '/apps/:name/restart/?(.:format)?' do
      authorize!
    end

    # Stop app
    post '/apps/:name/stop/?(.:format)?' do
      authorize!

      app = App.new(params[:name])

      action = App::Action.new(app, current_user)
      action.stop

      redirect to("/apps/#{app.name}/actions/#{action.id}")
    end

    # Start app
    post '/apps/:name/start/?(.:format)?' do
      authorize!

      app = App.new(params[:name])

      action = App::Action.new(app, current_user)
      action.start

      redirect to("/apps/#{app.name}/actions/#{action.id}")
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
