UncCarpool::App.controllers :volunteer do
  layout :site

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

  before :except => [:login, :new, :create, :confirm, :reset] do
    @user = Volunteer.first(id: session[:uid])
    if !@user
      return "403"
    end

    if !@user.confirmed?
      render('li', locals: {mes: 'volunteer not found'})
    end
  end

  get :reset do
    render 'volunteer/reset'
  end

  post :reset do
    email = params[:volunteer][:email]
    v = Volunteer.first(email: email)
    unless v
      render('li', locals: {mes: 'Email not found!'})
    else
      send_reset_email(v)
      render('li', locals: {mes: 'Email sent!'})
    end
  end

  get :repassword do
    c = params[:code]
    return "no such code" unless c
    v = Volunteer.first(email_code: c)
    unless v
      render('li', locals: {mes: 'Code not found!'})
    else
      #session[:tmp_uid] = v.id
      render 'volunteer/passreset', locals: {code: c}
    end
  end

  post :passreset do
    arg = params[:volunteer]
    v = Volunteer.first(arg[:code])
    if v.save
      render('li', locals: {mes: 'Reset success!'})
    else
      flash[:errors] = v.errors.map(&:to_s)
      render '/volunteer/repassword', locals: {code: c}
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
        flash[:errors] = @user.errors.map(&:to_s)
        redirect '/volunteer/update'
      end
    else

      attrs = params[:volunteer]
      @user.update(attrs)

      if @user.save
        flash[:success] = ["修改个人信息成功！"]
        redirect 'volunteer/update'
      else
        flash[:errors] = @user.errors.map(&:to_s)
        redirect '/volunteer/update'
      end
    end
  end

  get :riderize do
    render '/volunteer/riderize'
  end

  get :volunteerize do
    render '/volunteer/volunteerize'
  end

  post :riderize do
    vol = params[:volunteer]
    vol[:group] = :rider
    @user.update(vol)
    @user.save

    success '成功成为顺风车申请者！'

    redirect '/volunteer/me'
  end

  post :volunteerize do
    vol = params[:volunteer]
    vol[:group] = :volunteer
    @user.update(vol)
    @user.save

    redirect '/volunteer/me'
  end

  post :discardgroup do
    @user.group = :none
    @user.ans4 = ''
    @user.save
    success "成功取消当前特殊身份，现在是普通的活动参加者！"
    redirect '/volunteer/me'
  end

  post :take do
    reqs = json_or_single params[:id]
    reqs.each do |id|
      r = Volunteer.first(id: id)
      if !r
        return "404"
      else
        if r.parent
          return "403 taken"
        else
          @user.cocar.new(source: @user, target: r)
          @user.save
          r.volunteer << @user
          r.save
          vol = @user
          email do
            @vol = vol
            @req = r
            from "facss_carpool_service@unc.edu"
            to r.email
            content_type :html
            subject "FACSS Carpool Service 匹配成功"
            render 'email/request_taken'
          end
        end
      end
    end
    render('li', locals: {mes: '成功选择！前往个人 Dashboard 可以查看管理选择好的请求！'})
  end

  post :notactive do
    if params[:volunteer][:conf] == "放弃参与"
      @user.active = false
      @user.group = :none
      @user.ans1 = ''
      @user.ans2 = ''
      @user.ans3 = ''
      @user.ans4 = ''
      @user.delete_all_rider!
      @user.save
      redirect '/volunteer/me'
    else
      return "确认失败"
    end
  end

  post :enroll do
    @user.active = true
    @user.save

    redirect '/volunteer/me'
  end

  post :forfeit, :with => :id do
    require 'json'
    if after_deadline?
      return "403 after deadline"
    end
    reqs = json_or_single params[:id]
    reqs.each do |id|
      r = Volunteer.first(id: id)
      if !r
        return render('404', layout: 'site')
      elsif !r.parent
        return render('404', layout: 'site')
      else
        if r.parent.id == @user.id
          @user.cocar.find{|it| it.target.id == r.id}.destroy()
          r.volunteer = []
          r.save!
          @user.save!

          email do
            @vol = r.volunteer
            @req = r
            from "facss_carpool_service@unc.edu"
            to r.email
            content_type :html
            subject "FACSS Carpool Service 志愿者取消匹配"
            render 'email/request_forfeit'
          end
        else
          return "403 you don't have that"
        end
      end
    end
    render('li', locals: {mes: '成功放弃请求，对方会接受邮件提醒。'})
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

      session[:uid] = r.id
      redirect '/volunteer/me'
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
    redirect '/'
  end

  post :create do
    u = Volunteer.new(params[:volunteer])
    @req = u #Hack
    if u.save
      session[:uid] = u.id
      uri = uri(url(:volunteer, :confirm, code: u.email_code))
      email do
        @vol = u
        from "facss_carpool_service@unc.edu"
        to u.email
        content_type :html
        subject "FACSS 活动邮箱确认"
        render 'email/confirm', locals: {uri: uri, vol: u}
      end
      render('li', locals: {mes: '成功登记，为了保证邮箱正确请去注册邮箱点开“邮箱确认”邮件。'})
    else
      flash[:errors] = u.errors.map(&:to_s)
      redirect '/volunteer/new'
    end
  end
end