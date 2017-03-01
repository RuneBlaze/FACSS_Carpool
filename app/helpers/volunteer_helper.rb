# Helper methods defined here can be accessed in any controller or view in the application
require 'date'
module UncCarpool
  class App
    module VolunteerHelper
      # def simple_helper_method
      # ...
      # end

      def after_deadline?
         DEADLINE <= DateTime.now
      end

      def send_reset_email v
        v.new_email_code
        v.save
        target = v.email
        code = v.email_code

        email do
          from "facss_carpool_service@unc.edu"
          to target
          content_type :html
          subject "FACSS Carpool Service 密码重置"
          render 'email/reset', locals: {code: code}
        end
      end
    end

    helpers VolunteerHelper
  end
end
