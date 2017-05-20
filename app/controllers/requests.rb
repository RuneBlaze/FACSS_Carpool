UncCarpool::App.controllers :request do
  layout :site

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
    @reqs = Volunteer.all(group: :rider).select{|it| !it.parent}
    all = JSON.dump(@reqs.map{|it| [it.id, it.passengers]}.to_h).html_safe
    render 'request/all', layout: 'site', locals: {all: all}
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

      render('li', locals: {mes: 'confirmed!'})
    end
  end

  get :action, with: [:id, :type] do
    c = params[:type]
    r = Volunteer.first(id: params[:id].to_i)
    if !r
      return "bye"
    end

    case c
    when 'take'
      render('request/confirm_req', locals: {type: 'take', r: r})
    when 'forfeit'
      render('request/confirm_req', locals: {type: 'forfeit', r: r})
    else
      return 'not found'
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

  post :delete do
    return "cancel failed" if params[:sinatra_request][:yes] == "0"
    r = Request.first(conf: params[:sinatra_request][:conf])
    vol = r.volunteer
    unless (r.volunteer.nil?)
      r.volunteer.requests.delete_if {|it| it.id == r.id}
      r.volunteer.save!
      r.volunteer = nil
      r.save!
    end

    email do
      @req = r
      from "facss_carpool_service@unc.edu"
      to vol.email
      content_type :html
      subject "FACSS Carpool 接受请求被主动取消"
      render 'email/request_self_canceled', locals: {req: r, vol: vol}
    end
    r.destroy!
    render('li', locals: {mes: '已经被主动取消'})
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
