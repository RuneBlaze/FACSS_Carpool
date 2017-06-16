module UncCarpool
  class App < Padrino::Application
    use IdentityMap
    register Padrino::Mailer
    register Padrino::Helpers
    enable :sessions

    set :delivery_method, :smtp => {
      :address              => "smtp.postmarkapp.com",
      :port                 => 587,
      :user_name            => POSTMARK_KEY,
      :password             => POSTMARK_KEY,
      :authentication       => :plain,
      :enable_starttls_auto => true
    }

    before except: ['/construction', '/about'] do
      redirect '/construction' if $construction
      unless @user
        if session[:uid]
          @user = Volunteer.first(id: session[:uid])
        end
      end
    end

    get '/' do
      render 'index', layout: 'site'
    end

    get '/report' do
      render 'report', layout: 'site'
    end

    get '/about' do
      render 'about', layout: 'site'
    end

    get '/construction' do
      render 'construction', layout: 'site'
    end
  end
end
