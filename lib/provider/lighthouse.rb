module TicketMaster::Provider
  # This is the Lighthouse Provider for ticketmaster
  module Lighthouse
    include TicketMaster::Provider::Base
    PROJECT_API = ::Lighthouse::Project
    TICKET_API = ::Lighthouse::Ticket
    
    # This is for cases when you want to instantiate using TicketMaster::Provider::Lighthouse.new(auth)
    def self.new(auth = {})
      TicketMaster.new(:lighthouse, auth)
    end
    
    # The authorize and initializer for this provider
    def authorize(auth = {})
      @authentication ||= TicketMaster::Authenticator.new(auth)
      auth = @authentication
      if auth.account.nil? or (auth.token.nil? and (auth.username.nil? and auth.password.nil?))
        raise "Please provide at least an account (subdomain) and token or username and password)"
      end
      ::Lighthouse::Base.format = :xml
      ::Lighthouse.account = auth.account || auth.subdomain
      if auth.token
        ::Lighthouse.token = auth.token
      elsif auth.username && auth.password
        ::Lighthouse.authenticate(auth.username, auth.password)
      end
    end

    def valid?
      begin
        PROJECT_API.find(:first)
        true
      rescue
        false
      end
    end

    # The projects
    #
    # We have to merge in the auth information because, due to the class-based authentication
    # mechanism, if we don't reset the authorize information for every request, it would 
    # end up using whatever the previous instantiated object's account info is.
    def projects(*options)
      authorize
      super(*options)
    end

    # The project
    def project(*options)
      authorize
      super(*options)
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
      super(*options)
    end

    # the ticket
    def ticket(*options)
      authorize
      super(*options)
    end

  end
end
