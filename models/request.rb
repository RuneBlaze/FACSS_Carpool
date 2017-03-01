require 'securerandom'
class Request
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String, :required => true
  property :email, String, :required => true#, :unique => true
  property :gender, Enum[:male, :female, :other], :default => :male
  property :date, String, required: true
  property :time, String, required: true
  property :passengers, Integer, required: true, max: 30
  property :place, String, :required => true, :default => "UNC Chapel Hill"
  property :phone, String, :required => true, format: /^(\([0-9]{3}\) |[0-9]{3})[0-9]{3}[0-9]{4}$/
  property :weixin, String
  property :conf, String, :default => proc {SecureRandom.hex}, unique: true
  belongs_to :volunteer, :required => false

  property :confirmed, Boolean, default: false
  property :email_code, String, :default => proc {SecureRandom.hex}, unique: true

  def confirmed?
    return self.confirmed
  end
  validates_with_method :passengers, :method => :check_passengers

  def check_passengers
    return true unless self.volunteer
    filtered = volunteer.requests.select{|r| r.id != self.id}
    return true if filtered.empty?
    total = filtered.map(&:passengers).inject(:+) + self.passengers
    if total > volunteer.max_passengers
      [false, 'The new passenger count exceed that of the capacity of volunteer']
    else
      true
    end
  end
end
