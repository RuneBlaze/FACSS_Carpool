# Helper methods defined here can be accessed in any controller or view in the application
require 'date'
require 'json'
module UncCarpool
  class App
    module VolunteerHelper
      def after_deadline?
         DEADLINE <= DateTime.now
      end

      def json_or_single value
        if value.to_i > 0
          return [value.to_i]
        end

        begin
          JSON.parse(value)
        rescue JSON::ParserError => e
          return nil
        end
      end

      def send_reset_email v
        v.new_email_code
        v.save
        target = v.email
        code = v.email_code
        c = url_for(:volunteer, :repassword, code: code)
        email do
          from "facss_carpool_service@unc.edu"
          to target
          content_type :html
          subject "FACSS Carpool Service 密码重置"
          render 'email/reset', locals: {code: c}
        end
      end

      def send_reset_email_masu v
        v.new_email_code
        v.save
        target = v.email
        code = v.email_code
        c = url_for(:volunteer, :repassword, code: code)

        email do
          from "facss_carpool_service@unc.edu"
          to target
          content_type :html
          subject "FACSS Carpool Service 密码重置"
          render 'email/reset', locals: {code: c}
        end
      end

      def success_or_fail k, mes
        flash.now[k] = [] unless flash.now[k]
        if mes.is_a? Array
          flash.now[k] = flash.now[k].concat(mes)
        else
          flash.now[k] << mes
        end
      end

      def success mes
        success_or_fail :success, mes
      end

      def fail mes
        success_or_fail :success, mes
      end
    end

    helpers VolunteerHelper
  end
end
