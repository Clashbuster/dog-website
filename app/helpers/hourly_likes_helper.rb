module HourlyLikesHelper
  class HourlyLikes
    attr_accessor :past_hour, :current_hour, :begin

    def initialize
      @past_hour = {}
      @current_hour = {}
      @begin = true
    end

    def start
      puts "started"
      @begin = false
      Concurrent::Future.execute { sleep(5); reset_hour }
    end

    def reset_hour
      puts "reset"
      @past_hour = @current_hour
      @current_hour = {}
      Concurrent::Future.execute { sleep(5); reset_hour }
    end

    # def set_interval(delay)
    #     Rails.application.executor.wrap do
    #       th = Thread.new do
    #         Rails.application.executor.wrap do
    #           loop do
    #             sleep delay
    #             yield # call passed block
    #           end
    #         end
    #       end
        
    #       ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
    #         th.join # outer thread waits here, but has no lock
    #       end
    #     end
    # end

    def update_hourly(dog)
      if @current_hour[dog.id]
        @current_hour[dog.id] += 1
      else
        @current_hour[dog.id] = 1
      end
    end


  end
end
