module Barrister

  class IntraProcessTransport

    def initialize(service_container)
      @service_container = service_container
    end

    def request(message)
      @service_container.process message
    end

  end

end
