module TicketMaster::Provider
  module Lighthouse
    # Project class for ticketmaster-lighthouse
    # 
    # 
    class Project < TicketMaster::Provider::Base::Project
      # The finder method
      # 
      # It accepts all the find functionalities defined by ticketmaster
      #
      # + find() and find(:all) - Returns all projects on the account
      # + find(<project_id>) - Returns the project based on the id
      # + find(:first, :name => <project_name>) - Returns the first project based on the attribute
      # + find(:name => <project name>) - Returns all projects based on the attribute
      attr_accessor :prefix_options
      def self.find(*options)
        first = options.shift
        if first.nil? or first == :all
          LighthouseAPI::Project.find(:all).collect do |p|
            self.new p
          end
        elsif first.is_a?(Fixnum)
          self.new LighthouseAPI::Project.find(first)
        elsif first == :first
          self.new self.search(options.shift || {}, 1).first
        elsif first.is_a?(Hash)
          self.search(first).collect { |p| self.new p }
        end
      end
      
      # This is a helper method to find
      def self.search(options = {}, limit = 1000)
        projects = LighthouseAPI::Project.find(:all)
        projects.find_all do |p|
          options.keys.reduce(true) do |memo, key|
            p.send(key) == options[key] and (limit-=1) >= 0
          end
        end
      end
      
      # Create a project
      def self.create(*options)
        project = LighthouseAPI::Project.new(options.shift)
        project.save
        self.new project
      end
      
      # The initializer
      #
      # A side effect of Hashie causes prefix_options to become an instance of TicketMaster::Provider::Lighthouse::Project
      def initialize(*options)
        @system = :lighthouse
        @system_data = {}
        first = options.shift
        if first.is_a?(LighthouseAPI::Project)
          @system_data[:client] = first
          @prefix_options = first.prefix_options
          super(first.attributes)
        else
          super(first)
        end
      end
      
      # All tickets for this project
      def tickets(*options)
        if options.length == 0
          Ticket.find(:project_id => self.id)
        else
          first = options.first
          if first.is_a?(Fixnum)
            [Ticket.find(first, {:project_id => self.id})]
          else
            Ticket.find({:project_id => self.id}.merge(:q => options.first))
          end
        end
      end
      
      # The ticket finder
      # returns only one ticket
      def ticket(*options)
        first = options.shift
        if first.nil?
          return Ticket
        elsif first.is_a?(Fixnum)
          return Ticket.find(first, :project_id => self.id)
        else
          Ticket.find(:first, {:project_id => self.id}.merge(:q => first))
        end
      end

    end
  end
end
