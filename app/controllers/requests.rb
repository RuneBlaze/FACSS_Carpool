UncCarpool::App.controllers :request do

  # get :index, :map => '/foo/bar' do
  #   session[:foo] = 'bar'
  #   render 'index'
  # end

  # get :sample, :map => '/sample/url', :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   "Maps to url '/foo/#{params[:id]}'"
  # end

  # get '/example' do
  #   'Hello world!'
  # end

  get :new do
    render 'request/new', layout: 'site'
  end

  before :all do
    @user = Volunteer.first(id: session[:uid])
    if !@user
      return "403"
    end
  end

  get :all do
    @reqs = Request.all()
    render 'request/all', layout: 'site'
  end

  post :create do
    @req = Request.new(params[:sinatra_request])
    if @req.save
      
    else
      flash[:errors] = @req.errors.map(&:to_s)

      redirect '/request/new'
    end
  end

end
