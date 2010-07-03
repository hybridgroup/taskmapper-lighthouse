module TicketMaster::Provider
  module Lighthouse
    # Project class for ticketmaster-lighthouse
    # 
    # 
    class Project < TicketMaster::Provider::Base::Project
      attr_accessor :prefix_options
      API = LighthouseAPI::Project
      # Delete this project
      def destroy
        result = super
        result.is_a?(Net::HTTPOK)
      end

    end
  end
end
