module TicketMasterMod
  module Lighthouse
    class Project
      def self.find(query, options = {})
        self.authenticate(options[:authentication]) if options[:authentication]
        projects = LighthouseAPI::Project.find :all # Kernel::Lighthouse::Project.find query
        formatted_projects = []

        unless projects.empty?
          projects.each do |project|
            attributes = {:system => "lighthouse", :authentication => options[:authentication],
              :system_data => {:project => project}}
            attributes.merge!(project.attributes)
            formatted_projects << TicketMasterMod::Project.new(attributes)
          end
        end

        formatted_projects
      end
      
      def self.authenticate(auth)
        LighthouseAPI.account = auth.account || auth.subdomain
        if auth.token
          LighthouseAPI.token = auth.token
        elsif auth.username && auth.password
          LighthouseAPI.authenticate(auth.username, auth.password)
        end
      end

      def self.tickets(project_instance)
        self.authenticate(project_instance.authentication)
        tickets = project_instance.system_data[:project].tickets
        formatted_tickets = []

        unless tickets.empty?
          tickets.each do |ticket|
            attributes = {:system => 'lighthouse', :project => project_instance,
              :system_data => {:project => project_instance.system_data[:project], :ticket => ticket}}
            attributes.merge!(ticket.attributes)
            formatted_tickets << TicketMasterMod::Ticket.new(attributes)
          end
        end

        formatted_tickets
      end
    end
  end
end
