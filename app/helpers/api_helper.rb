# Helper methods defined here can be accessed in any controller or view in the application

module UncCarpool
  class App
    module ApiHelper
      # def simple_helper_method
      # ...
      # end

      def lift_user v
        return Volunteer.first(id: v)
      end
    end

    helpers ApiHelper
  end
end
