module TicketMaster::Provider
  # This is the Lighthouse Provider for ticketmaster
  module Lighthouse
    include TicketMaster::Provider::Base
    
    # This is for cases when you want to instantiate using TicketMaster::Provider::Lighthouse.new(auth)
    def self.new(auth = {})
      TicketMaster.new(:lighthouse, auth)
    end
    
    # The authorize and initializer for this provider
    def authorize(auth = {})
      @authentication ||= TicketMaster::Authenticator.new(auth)
      auth = @authentication
      LighthouseAPI.account = auth.account || auth.subdomain
      if auth.token
        LighthouseAPI.token = auth.token
      elsif auth.username && auth.password
        LighthouseAPI.authenticate(auth.username, auth.password)
      end
    end
    
    # The projects
    #
    # We have to merge in the auth information because, due to the class-based authentication
    # mechanism, if we don't reset the authorize information for every request, it would 
    # end up using whatever the previous instantiated object's account info is.
    def projects(*options)
      authorize
      projects = if options.length > 0
        Project.find(*options)
        else
        Project.find(:all)
        end
      set_master_data(projects)
    end
    
    # The project
    def project(*options)
      authorize
      return set_master_data(Project.find(:first, *options)) if options.length > 0
      Project
    end
    
    # The tickets
    #
    # Due to the nature of lighthouse, we must have the project_id to pull tickets. You can
    # pass in the id through this format:
    # 
    #    .tickets(22)
    #    .tickets(:project_id => 22)
    # 
    # To conform to ticketmaster's standard of returning all tickets on a call to this method
    # without any parameters, if no parameters are passed, it will return all tickets for whatever
    # the first project is.
    def tickets(*options)
      authorize
      arg = options.shift
      tickets = if arg.nil?
        Ticket.find
        elsif arg.is_a?(Fixnum)
        Ticket.find(:all, :params => {:project_id => arg})
        elsif arg.is_a?(Hash)
        Ticket.find(:all, :params => arg) if arg.is_a?(Hash)
        else
        []
        end
      set_master_data(tickets)
    end
    
    # the ticket
    def ticket(*options)
      authorize
      return set_master_data(Ticket.find(*options)) if options.length > 0
      Ticket
    end
    
    def set_master_data(data)
      if data.is_a?(Array)
        data.collect! { |p| p.system_data.merge!(:master => self); p }
      else
        data.system_data.merge!(:master => self)
      end
      data
    end
  end
end
