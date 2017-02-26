UncCarpool::Admin.controllers :volunteers do
  get :index do
    @title = "Volunteers"
    @volunteers = Volunteer.all
    render 'volunteers/index'
  end

  get :new do
    @title = pat(:new_title, :model => 'volunteer')
    @volunteer = Volunteer.new
    render 'volunteers/new'
  end

  post :create do
    @volunteer = Volunteer.new(params[:volunteer])
    if @volunteer.save
      @title = pat(:create_title, :model => "volunteer #{@volunteer.id}")
      flash[:success] = pat(:create_success, :model => 'Volunteer')
      params[:save_and_continue] ? redirect(url(:volunteers, :index)) : redirect(url(:volunteers, :edit, :id => @volunteer.id))
    else
      @title = pat(:create_title, :model => 'volunteer')
      flash.now[:error] = pat(:create_error, :model => 'volunteer')
      render 'volunteers/new'
    end
  end

  get :edit, :with => :id do
    @title = pat(:edit_title, :model => "volunteer #{params[:id]}")
    @volunteer = Volunteer.get(params[:id])
    if @volunteer
      render 'volunteers/edit'
    else
      flash[:warning] = pat(:create_error, :model => 'volunteer', :id => "#{params[:id]}")
      halt 404
    end
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "volunteer #{params[:id]}")
    @volunteer = Volunteer.get(params[:id])
    if @volunteer
      if @volunteer.update(params[:volunteer])
        flash[:success] = pat(:update_success, :model => 'Volunteer', :id =>  "#{params[:id]}")
        params[:save_and_continue] ?
          redirect(url(:volunteers, :index)) :
          redirect(url(:volunteers, :edit, :id => @volunteer.id))
      else
        flash.now[:error] = pat(:update_error, :model => 'volunteer')
        render 'volunteers/edit'
      end
    else
      flash[:warning] = pat(:update_warning, :model => 'volunteer', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy, :with => :id do
    @title = "Volunteers"
    volunteer = Volunteer.get(params[:id])
    if volunteer
      if volunteer.destroy
        flash[:success] = pat(:delete_success, :model => 'Volunteer', :id => "#{params[:id]}")
      else
        flash[:error] = pat(:delete_error, :model => 'volunteer')
      end
      redirect url(:volunteers, :index)
    else
      flash[:warning] = pat(:delete_warning, :model => 'volunteer', :id => "#{params[:id]}")
      halt 404
    end
  end

  delete :destroy_many do
    @title = "Volunteers"
    unless params[:volunteer_ids]
      flash[:error] = pat(:destroy_many_error, :model => 'volunteer')
      redirect(url(:volunteers, :index))
    end
    ids = params[:volunteer_ids].split(',').map(&:strip)
    volunteers = Volunteer.all(:id => ids)
    
    if volunteers.destroy
    
      flash[:success] = pat(:destroy_many_success, :model => 'Volunteers', :ids => "#{ids.join(', ')}")
    end
    redirect url(:volunteers, :index)
  end
end
