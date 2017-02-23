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
  property :passengers, Integer, :default => 1
  property :place, String, :required => true, :default => "UNC Chapel Hill"
  property :phone, String, :required => true, format: /^(\([0-9]{3}\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$/
  property :weixin, String
  property :conf, String, :default => proc {SecureRandom.hex}, unique: true
  belongs_to :volunteer, :required => false

  property :confirmed, Boolean, default: false
  property :email_code, String, :default => proc {SecureRandom.hex}, unique: true

  def confirmed?
    return self.confirmed
  end
end
