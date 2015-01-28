module Hob
  class Web < Sinatra::Base

    # List apps
    get '/' do

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

    end

    post '/apps/.?:format?' do

    end

    # Show app
    get '/apps/:name.?:format?' do

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

  end
end
