class Request
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String, :required => true
  property :email, String, :required => true#, :unique => true
  property :gender, Enum[:male, :female, :other], :default => :male
  property :date, String
  property :time, String
  property :passengers, Integer, :default => 1
  property :school, String
  property :place, String, :required => true
  property :phone, String
  property :weixin, String
  property :qq, String
  property :conf, String, :default => proc {SecureRandom.hex}

  belongs_to :volunteer, :required => false

  validates_with_method :check_weixin_or_qq
  def check_weixin_or_qq
    res = (self.qq && self.weixin) && (self.qq != "" || self.weixin != "")
    if res
      return true
    else
      return [false, "微信以及 QQ 中必须填一项。"]
    end
  end
end
