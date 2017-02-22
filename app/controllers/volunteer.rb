UncCarpool::App.controllers :volunteer do
  enable :sessions

  get :new do
    render 'volunteer/new'
  end

  get :all do
    @reqs = Request.all()
    render 'volunteer/all'
  end

  get :login do
    render 'volunteer/login'
  end

  before :except => [:login, :new, :create] do
    @user = Volunteer.first(id: session[:uid])
    if !@user
      return "403"
    end
  end

  get :me do
    render 'volunteer/me'
  end

  post :take, :with => :id do
    r = Request.first(id: params[:id].to_i)
    if !r
      return "404"
    else
      if r.volunteer
        return "403 taken"
      else
        @user.requests << r
        @user.save
        r.volunteer = @user
        r.save
        return "taken"
      end
    end
  end

  post :forfeit, :with => :id do
    r = Request.first(id: params[:id].to_i)
    if !r
      return "404"
    else
      if r.volunteer.id == @user.id
        r.volunteer = nil
        r.save
        return "forfeit"
      else
        return "403 you don't have that"
      end
    end
  end

  post :login do
    v = Volunteer.first(email: params[:volunteer][:email])
    if !v
      return "用户不存在"
    end
    if v.password != params[:volunteer][:password]
      return "密码错误"
    end
    session[:uid] = v.id
    return "login success!"
  end

  post :create do
    p params
    @req = Volunteer.new(params[:volunteer])
    if @req.save
      return "注册成功！"
    else
      flash[:errors] = @req.errors.map(&:to_s)
      redirect '/volunteer/new'
    end
  end


end
