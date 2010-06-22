module TicketMaster::Provider
  module Lighthouse
    # Ticket class for ticketmaster-lighthouse
    class Ticket < TicketMaster::Provider::Base::Ticket
      # This is an exhaustive list, but should contain the most common ones, add as necessary
      @@allowed_attributes = ["number", "permalink", "milestone_id", "created_at", "title", "closed", "updated_at", "raw_data", "priority", "tag", "url", "attachments_count", "creator_id", "milestone_due_on", "original_body_html", "user_id", "user_name", "original_body", "latest_body", "assigned_user_id", "creator_name", "state"]
      @@allowed_states = ['new', 'open', 'resolved', 'hold', 'invalid']
      attr_accessor :prefix_options
      
      # The finder
      #
      # It tries to implement all the ticketmaster calls, but since the project id is required as the
      # parent key, it doesnt really make sense to call find(:all) or find(##)
      # 
      # * find(:all) - Returns an array of all tickets
      # * find(##, ##) - Returns a ticket based on that id or some other primary (unique) attribute
      # * find(:first, :summary => 'Ticket title') - Returns a ticket based on the ticket's attributes
      # * find(:summary => 'Test Ticket') - Returns all tickets based on the given attributes
      def self.find(*options)
        first = options.shift
        if first.nil? or first == :all
          tickets = []
          LighthouseAPI::Project.find(:all).each do |p|
            tickets |= p.tickets
          end
          tickets.collect { |t| self.new t }
        elsif first.is_a?(Fixnum)
          second = options.shift
          if second.is_a?(Fixnum)
            self.new LighthouseAPI::Ticket.find(first, :params => { :project_id => second })
          elsif second.is_a?(Hash)
            self.new LighthouseAPI::Ticket.find(first, :params => qize(second))
          end
        elsif first == :first
          self.new self.search(options.shift, 1).first
        elsif first.is_a?(Hash)
          self.search(first).collect do |t| self.new t end
        end
      end
      
      
      def self.qize(params)
        return params unless params[:q] and params[:q].is_a?(Hash)
        q = ''
        params[:q].keys.each do |key|
          value = params[:q][key]
          value = "\"#{value}\"" if value.to_s.include?(' ')
          q += "#{key}:#{value} "
        end
        params[:q] = q
        params
      end
      
      # The find helper
      def self.search(options, limit = 1000)
        tickets = LighthouseAPI::Ticket.find(:all, :params => qize(options))
        options.delete(:project_id) || options.delete('project_id')
        tickets.find_all do |t|
          options.keys.reduce(true) do |memo, key|
            p.send(key) == options[key] and (limit-=1) > 0
          end
        end
      end
      
      # The initializer
      def initialize(*options)
        @system = :lighthouse
        @system_data = {}
        first = options.shift
        if first.is_a?(LighthouseAPI::Ticket)
          @system_data[:client] = first
          @prefix_options = first.prefix_options
          super(first.attributes)
        else
          super(first)
        end
      end
      
      # The creator
      def self.create(*options)
        ticket_attr = options.delete_if { |k, v| !@@allowed_attributes.include?(k) }
        new_ticket = LighthouseAPI::Ticket.new(ticket_attr)
        ticket_attr.delete(:project_id) || ticket_attr.delete('project_id')
        ticket_attr.each do |k, v|
          new_ticket.send(k + '=', v)
        end
        new_ticket.save
      end
      
      # The saver
      def save
        ticket_attr = self.to_hash.delete_if { |k, v| !@@allowed_attributes.include?(k) || ticket.system_data[:client].send(k) == v }
        lh_ticket = ticket.system_data[:client]
        ticket_attr.each do |k, v|
          lh_ticket.send(k + '=', v)
        end
        lh_ticket.save
      end
      
      # The closer
      def close(resolution = 'resolved')
        resolution = 'resolved' unless @@allowed_states.include?(resolution)
        ticket = LighthouseAPI::Ticket.find(self.id, :params => {:project_id => self.prefix_options[:project_id]})
        ticket.state = resolution
        ticket.save
      end
    end
  end
end
