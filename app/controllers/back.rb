require 'csv'
UncCarpool::App.controllers :back do
  
  enable :sessions
  layout :site

  # before except: [:index, :session] do
    # unless session[:manage]
    #   redirect '/back/index'
    # end
  # end

  get :index do
    render 'manage/index'
  end

  get :connect do
    @all = Volunteer.all(group: :volunteer)
    render 'manage/connect'
  end

  get :session do
    render 'manage/login'
  end

  get :email_all do
    render 'manage/emailer'
  end

  post :session do
    v = Account.authenticate(params[:account][:email], params[:account][:password])
    if v
      session[:manage] = v
      redirect '/back'
    else
      return 'Login Failed'
    end
  end

  post :connect, with: [:lhs, :rhs] do
    lhs = params[:lhs]
    rhs = params[:rhs]
    vol = lift_user lhs
    rid = lift_user rhs
    if !(vol && rid)
      return 'not found'
    else
      vol.take_as_rider! rid
      return 'success'
    end
  end
  

  post :forfeit, with: [:lhs, :rhs] do
    lhs = params[:lhs]
    rhs = params[:rhs]
    vol = lift_user lhs
    rid = lift_user rhs
    if !(vol && rid)
      return 'not found'
    else
      vol.delete_rider! rid
      return 'success'
    end
  end

  post :batch_email, with: [:group] do
    g = params[:group]
  end


  HEADERS = %w{
    Name Gender Weixin Phone Email Grade 分配的志愿者 Group 出发地点 总共拼车人数 总共承载人数
  }
  get :roster_csv do
    res = CSV.generate do |csv|
      csv << HEADERS
      Volunteer.all().each do |v|
        csv << [v.name, v.gender, v.weixin, v.phone, v.email, v.grade,
          v.parent ? v.parent.name : "None",
          v.group, v.place, v.passengers, v.max_passengers]
      end
    end
    content_type 'application/csv'
    attachment 'facss-carpool-roster.csv'
    res
  end

end
