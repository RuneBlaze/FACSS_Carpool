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
  property :phone, String, :required => true, format: /^(\([0-9]{3}\) |[0-9]{3})[0-9]{3}[0-9]{4}$/
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

  def confirmed?
    return self.confirmed
  end

  def new_email_code
    self.email_code = SecureRandom.hex
  end

  def passengers_count
    return 0 if self.cocar.empty?
    self.cocar.map{|it| it.target.passengers}.inject(:+)
  end

  def rest_passengers
    return max_passengers - passengers_count
  end

  def can_take_request? rhs
    rhs.passengers <= rest_passengers
  end
end

class Cocar
  include DataMapper::Resource

  belongs_to :source, 'Volunteer', key: true
  belongs_to :target, 'Volunteer', key: true
end
