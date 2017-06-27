#Name,Gender,Weixin,Phone,Email,Grade,Volunteer,Group,Ans1,Ans2,Ans3,时间段
def reconstruct_data str
    pwd = str[4].split("@")[0].chars.shuffle.join + "#{rand(1000)}"
    v = Volunteer.create(
        name: str[0],
        password: pwd,
        gender: str[1],
        weixin: str[2],
        phone: str[3],
        email: str[4],
        grade: str[5].downcase.to_sym,
        group: str[7].downcase.to_sym,
        ans1: str[8],
        ans2: str[9],
        ans3: str[10],
        confirmed: true,
        ans4: str[11] &&! str[11].include?(':') ? recons(str[11]) : nil
    )
    unless v.saved?
        raise 'not saved!'
    end
end


require 'json'
TIME_DIC = [0,3,6,9,12,15,18,21].map{|it| "#{it}-#{it+3}"}
STR = "10 0-3 11 0-3 12 3-6 12 0-3 12 0-3 13 0-3 13 3-6 13 0-3 14 0-3 15 0-3 16 0-3 18 0-3 19 0-3 20 0-3 17 0-3 12 0-3 13 0-3 19 0-3 19 3-6 19 0-3 20 0-3 20 3-6 20 0-3"
def recons s
    buf = []
    toks = s.split(" ")
    groups = []
    for i in 0...(toks.size / 2)
        groups << [toks[i* 2], toks[i*2 + 1]]
    end
    groups.each do |e|
        lhs = e[0].to_i
        rhs = e[1]
        id = TIME_DIC.find_index(rhs)
        buf << (lhs - 10) * 8 + id
    end 
    buf.uniq!
    return buf.to_json
end