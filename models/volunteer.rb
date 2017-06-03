require 'json'
class Volunteer
  include DataMapper::Resource

  has n, :cocar, child_key: :source_id
  has n, :volunteer, self, through: :cocar, via: :target

  # Normal User Properties
  property :id, Serial
  property :email, String, :format => :email_address, :required => true, :unique => true
  property :password, BCryptHash
  property :name, String, :required => true
  property :gender, Enum[:male, :female, :other], :default => :male
  property :place, Text
  property :grade, Enum[:undergrad, :grad, :phd, :prof, :alumni, :visiting], default: :undergrad

  # property :school, String, :unique => true
  property :phone, String, :required => true, format: /^(\([0-9]{3}\) |[0-9]{3})[0-9]{3}[0-9]{4,5}$/
  property :weixin, String

  # Auxilary Properties
  property :group, Enum[:none, :rider, :volunteer], default: :none

  # Volunteer Properties
  property :max_passengers, Integer#, required: true
  property :memo, Text

  # Rider Properties
  property :passengers, Integer, max: 30
  property :place, String

  # Security Properties
  property :confirmed, Boolean, default: false
  property :email_code, String, :default => proc {SecureRandom.hex}, unique: true
  property :password_token, String, :default => proc {SecureRandom.hex}, unique: true

  property :ans1, String
  property :ans2, String
  property :ans3, String
  property :ans4, String

  property :active, Boolean, default: true

  def confirmed?
    return self.confirmed
  end

  def new_email_code
    self.email_code = SecureRandom.hex
  end

  def passengers_count
    return 0 if self.children.empty?
    self.children.map{|it| it.passengers}.inject(:+)
  end

  def children
    self.cocar.map{|it| it.target}.select{|it| it.parent && it.parent.id == self.id}
  end

  def parent
    self.volunteer[0]
  end

  def rest_passengers
    return max_passengers - passengers_count
  end

  def can_take_request? rhs
    rhs.passengers <= rest_passengers
  end

  def reqs_json
    self.cocar.map{|it| it.target}
  end

  alias raw_max_passengers max_passengers
  def max_passengers
    self.raw_max_passengers || 1
  end

  def bitfield
    return ans4
  end

  def inclined_taking? v
    if v.ans2.nil? || v.ans2.empty?
      return false
    end
    value = v.ans2
    lhs = nil
    begin
      lhs = DateTime.parse value
    rescue ArgumentError => exception
      return false
    end
    rhs = DateTime.parse "2017-08-10 00:00"
    ic = JSON.parse(v.ans4)
    i = ((lhs - rhs) * 8).to_i
    return ic.include? i
  end

  def take_as_rider! rhs 
    if rhs.parent
      return [:failed, ""]
    else
      self.cocar.new(source: self, target: rhs)
      self.save
      rhs.volunteer << self
      rhs.save
      return [:ok, self]
    end
  end

  def delete_rider! r
    if !r
      return nil
    elsif !r.parent
      return [:failed, ""]
    else
      if r.parent.id == self.id
        self.cocar.find{|it| it.target.id == r.id}.destroy()
        r.volunteer = []
        r.save!
        self.save!
        email do
            @vol = self
            @req = r
            from "facss_carpool_service@unc.edu"
            to r.email
            content_type :html
            subject "FACSS Carpool Service 志愿者取消匹配"
            render 'email/request_forfeit'
        end
        return [:ok, self]
      else
        return [:failed, "permission denied"]
      end
    end
  end

  def delete_all_rider!
    self.children.each do |c|
      self.delete_rider! c
    end
  end


  TIME_DIC = [0,3,6,9,12,15,18,21].map{|it| "#{it}-#{it+3}"}
  def time_range
    if self.group == :none
      return nil
    elsif self.group == :volunteer
      return "" unless self.ans4
      buf = ""
      ranges = JSON.parse(self.ans4)
      ranges.each do |r|
        day = 10 + r / 8
        rg = TIME_DIC[day[r % 8]]
        buf += "#{day} #{rg}"
      end
      return buf
    elsif self.group == :rider
      return self.ans2
    end
    # return [] if ans4.nil?
    # buf = []
    # translate_dic = %w{时间段1 时间段2 时间段3 时间段4 时间段5 时间段6 时间段7 时间段8 时间段9 时间段10}
    # ans4.to_i.to_s(2).chars.reverse.each_with_index do |e, i|
    #   if e == '1'
    #     buf << translate_dic[i]
    #   end
    # end
    # return buf
  end

  def self.clean_metadata! pw
    if pw != 'confirm'
      return 'please add parameter "confirm"'
    end

    all = Volunteer.all()
    all.each do |lhs|
      lhs.children.each do |rhs|
        lhs.delete_rider! rhs
      end

      lhs.ans1 = ""
      lhs.ans2 = ""
      lhs.ans3 = ""
      lhs.ans4 = ""

      lhs.passengers = 1
      lhs.memo = ""

      lhs.group = :none

      lhs.save!
    end
  end
  
end

class Cocar
  include DataMapper::Resource

  belongs_to :source, 'Volunteer', key: true
  belongs_to :target, 'Volunteer', key: true
end

UserType = GraphQL::ObjectType.define do
  name "User"
  description "The User"

  field :id, !types.ID
end

QueryType = GraphQL::ObjectType.define do
  name "Query"

  field :user do
    type UserType
    argument :id, !types.ID
    resolve ->(obj, args, ctx) { Post.find(args['id']) }
  end
end

Schema = GraphQL::Schema.define do
  query QueryType
end