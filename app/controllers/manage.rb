require 'csv'
UncCarpool::App.controllers :manage do
  layout :site

  before except: [:index, :session] do
    unless session[:admin]
      redirect '/manage/login'
    end
  end

  get :index do
    unless session[:admin]
      redirect '/manage/session'
    else
      render 'manage/index'
    end
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
      session[:admin] = v
      redirect '/manage'
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

  get :roster_csv do
    res = CSV.generate do |csv|
      csv << ["Name", "Gender", "Weixin", "Phone", "Email", "Grade", "Volunteer", "Group", "Ans1", "Ans2", "Ans3", "时间段"]
      Volunteer.all().each do |v|
        csv << [v.name, v.gender, v.weixin, v.phone, v.email, v.grade,
          v.parent ? v.parent.name : "None",
          v.group, v.ans1, v.ans2, v.ans3, v.time_range.join("、")]
      end
    end
    content_type 'application/csv'
    attachment 'facss-carpool-roster.csv'
    res
  end
end
