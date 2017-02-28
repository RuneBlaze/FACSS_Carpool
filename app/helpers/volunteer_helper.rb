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
    end

    helpers VolunteerHelper
  end
end
