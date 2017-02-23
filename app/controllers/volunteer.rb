UncCarpool::App.controllers :volunteer do
  enable :sessions

  get :new do
    render 'volunteer/new', layout: 'site'
  end

  get :all do
    @reqs = Request.all()
    render 'volunteer/all', layout: 'site'
  end

  get :login do
    render 'volunteer/login', layout: 'site'
  end

  before :except => [:login, :new, :create, :confirm] do
    @user = Volunteer.first(id: session[:uid])
    if !@user
      return "403"
    end

    if !@user.confirmed?
      return "email not confirmed yet"
    end
  end

  get :me do
    render 'volunteer/me', layout: 'site'
  end

  get :update do
    render 'volunteer/update', layout: 'site'
  end

  post :update do
    if old_pass = params[:volunteer][:old_password]
      new_pass = params[:volunteer][:new_password]
      if @user.password == old_pass
        @user.password = new_pass
        flash[:success] = ["密码正确"]
      else
        flash[:errors] = ["旧密码不正确！"]
      end
      if @user.save
        redirect 'volunteer/update'
      else
        flash[:errors] = @req.errors.map(&:to_s)
        redirect '/volunteer/update'
      end
    else
      attrs = params[:volunteer]
      @user.update(attrs)

      if @user.save
        redirect 'volunteer/update'
      else
        flash[:errors] = @req.errors.map(&:to_s)
        redirect '/volunteer/update'
      end
    end
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
        @user.requests.delete_if {|it| it.id == r.id}
        r.volunteer = nil
        r.save!
        @user.save!
        return "forfeit"
      else
        return "403 you don't have that"
      end
    end
  end

  get :confirm do
    c = params[:code]
    if !c
      return "no confirmation code specified"
    else
      r = Volunteer.first(email_code: c)
      if !r
        return "no volunteer found with conf code"
      end

      if r.confirmed?
        return "email already confirmed"
      end

      r.confirmed = true
      r.save

      return "email confirmed!"
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
    redirect '/volunteer/me'
  end

  post :logout do
    session[:uid] = nil
    return "logout"
  end

  post :create do
    u = Volunteer.new(params[:volunteer])
    @req = u #Hack
    if u.save
      session[:uid] = u.id
      email do
        from "facss_carpool_service@unc.edu"
        to u.email
        subject "FACSS Carpool Service Email Confirmation"
        body render('email/confirm')
      end
      redirect '/volunteer/me'
    else
      flash[:errors] = u.errors.map(&:to_s)
      redirect '/volunteer/new'
    end
  end
end
