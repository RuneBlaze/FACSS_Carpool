require 'csv'
UncCarpool::App.controllers :manage do
  layout :site

  get :index do
    render 'manage/index'
  end

  get :roster_csv do
    res = CSV.generate do |csv|
      csv << ["Name", "Gender", "Weixin", "Phone", "Email", "Grade", "Volunteer", "Group", "Ans1", "Ans2", "Ans3"]
      Volunteer.all().each do |v|
        csv << [v.name, v.gender, v.weixin, v.phone, v.email, v.grade,
          v.parent ? v.parent.name : "None",
          v.group, v.ans1, v.ans2, v.ans3]
      end
    end
    content_type 'application/csv'
    attachment 'facss-carpool-roster.csv'
    res
  end
end
