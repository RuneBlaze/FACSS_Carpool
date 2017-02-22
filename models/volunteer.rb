class Volunteer
  include DataMapper::Resource

  has n, :requests

  # property <name>, <type>
  property :id, Serial
  property :email, String, :format => :email_address, :required => true, :unique => true
  property :password, BCryptHash
  property :name, String, :required => true
  property :gender, Enum[:male, :female, :other], :default => :male
  property :school, String, :unique => true
  property :phone, String
  property :weixin, String
  property :qq, String
end
