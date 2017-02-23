UncCarpool::App.controllers :request do

  get :new do
    render 'request/new', layout: 'site'
  end

  before :all do
    @user = Volunteer.first(id: session[:uid])
    if !@user
      render('li', locals: {mes: 'volunteer not found'})
    end
  end

  get :all do
    @reqs = Request.all(confirmed: true)
    render 'request/all', layout: 'site'
  end

  get :edit do
    render 'request/edit_route', layout: 'site'
  end


  # FIXME:
  # this part looks particularly ugly
  # in future refactors, we should probably
  # look into more elegant solutions
  post :edit do
    conf_code = params[:sinatra_request][:conf]
    @req = Request.first(conf: conf_code)
    if @req
      @req.update(params[:sinatra_request])
      if @req.save
        flash[:success] = ['修改成功！']
        return 'success'
      else
        flash[:errors] = @req.errors.map(&:to_s)
        render '/request/edit'
      end
    else
      msg = '未找到匹配 Confirmation Code，这代表系统出现了错误请联系管理员。'
      flash[:errors] = [msg]
      redirect '/request/edit'
    end
  end

  get :confirm do
    c = params[:code]
    if !c
      return "no confirmation code specified"
    else
      r = Request.first(email_code: c)
      if !r
        return "no request found with conf code"
      end

      if r.confirmed?
        return "email already confirmed"
      end

      r.confirmed = true
      r.save

      render('li', locals: {mes: 'email confirmed!'})
    end
  end

  get :conf do
    conf_code = params[:conf]
    @req = Request.first(conf: conf_code)
    if @req
      render '/request/edit'
    else
      flash[:errors] = ['未找到匹配 Confirmation Code']
      redirect '/request/edit'
    end
  end

  post :conf do
    conf_code = params[:sinatra_request][:conf]
    @req = Request.first(conf: conf_code)
    if @req
      render '/request/edit'
    else
      flash[:errors] = ['未找到匹配 Confirmation Code']
      redirect '/request/edit'
    end
  end

  post :create do
    @req = Request.new(params[:sinatra_request])
    if @req.save
      r = @req
      uri_conf = uri(url(:request, :confirm, code: r.email_code))
      uri_alter = uri(url(:request, :conf, conf: r.conf))
      email do
        @req = r
        from "facss_carpool_service@unc.edu"
        to @req.email
        content_type :html
        subject "FACSS Carpool 请求确认"
        render 'email/request_made', locals: {req: r, uri_conf: uri_conf, uri_alter: uri_alter}
      end
      render 'request/success', layout: 'site'
    else
      flash[:errors] = @req.errors.map(&:to_s)
      redirect '/request/new'
    end
  end
end
