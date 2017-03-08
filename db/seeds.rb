# Seed add you the ability to populate your db.
# We provide you a basic shell for interaction with the end user.
# So try some code like below:
#
#   name = shell.ask("What's your name?")
#   shell.say name
#

def gen_account
  email     = shell.ask "Which email do you want use for logging into admin?"
  password  = shell.ask "Tell me the password to use:", :echo => false

  shell.say ""

  account = Account.new(:email => email, :name => "Foo", :surname => "Bar", :password => password, :password_confirmation => password, :role => "admin")

  if account.valid?
    account.save
    shell.say "================================================================="
    shell.say "Account has been successfully created, now you can login with:"
    shell.say "================================================================="
    shell.say "   email: #{email}"
    shell.say "   password: #{?* * password.length}"
    shell.say "================================================================="
  else
    shell.say "Sorry, but something went wrong!"
    shell.say ""
    account.errors.full_messages.each { |m| shell.say "   - #{m}" }
  end
end

def gen_fake
  require 'faker'

  def gen_fake_volunteer_account
    user = Volunteer.new(
      name: Faker::Name.name,
      email: Faker::Internet.email,
      group: :volunteer,
      password: "111111",
      gender: [:male, :female].sample,
      place: Faker::Address.street_address + "\n" + Faker::Address.secondary_address,
      grade: [:undergrad, :grad, :phd, :prof, :alumni, :visiting].sample,
      phone: Array.new(10){rand(10).to_s}.join(''),
      weixin: Faker::Pokemon.name,
      max_passengers: rand(5) + 3,
      confirmed: true
    )

    if user.valid?
      user.save
      shell.say "user valid: #{user.name}, #{user.email}"
    else
      shell.say "Sorry, but something went wrong!"
      shell.say ""
      user.errors.full_messages.each { |m| shell.say "   - #{m}" }
    end

    def gen_fake_rider_account
      user = Volunteer.new(
        name: Faker::Name.name,
        email: Faker::Internet.email,
        group: :rider,
        password: "111111",
        gender: [:male, :female].sample,
        place: Faker::Address.street_address + "\n" + Faker::Address.secondary_address,
        grade: [:undergrad, :grad, :phd, :prof, :alumni, :visiting].sample,
        phone: Array.new(10){rand(10).to_s}.join(''),
        weixin: Faker::Pokemon.name,
        passengers: rand(3) + 1,
        confirmed: true
      )

      if user.valid?
        user.save
        shell.say "user valid: #{user.name}, #{user.email}"
      else
        shell.say "Sorry, but something went wrong!"
        shell.say ""
        user.errors.full_messages.each { |m| shell.say "   - #{m}" }
      end
    end
  end

  10.times do
    gen_fake_volunteer_account
    gen_fake_rider_account
  end
end

choice = shell.ask "generate new admin account, or populate the database with test data? (1, 2)"
case choice.to_i
when 1
  gen_account
when 2
  gen_fake
end
