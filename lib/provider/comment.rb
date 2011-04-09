module TicketMaster::Provider
  module Lighthouse
    # The comment class for ticketmaster-lighthouse
    #
    # Due to the way lighthouse handles tickets, comments aren't really comments, but
    # versions of the ticket.
    #
    # * author => user_name (read-only)
    # * body => description
    # * id => position in the versions array (set by the initializer)
    # * created_at
    # * updated_at
    # * ticket_id => number (read-only)
    # * project_id => (set by the initializer)
    class Comment < TicketMaster::Provider::Base::Comment
      API = ::Lighthouse::Ticket
      
      # A custom find_by_id
      # The "comment" id is it's index in the versions array. An id of 0 therefore exists and
      # should be the first ticket (original)
      def self.find_by_id(project_id, ticket_id, id)
        self.new API.find(ticket_id, :params => {:project_id => project_id}), id
      end

      # A custom find_by_attributes
      #
      def self.find_by_attributes(project_id, ticket_id, attributes = {})
        result = self.search(project_id, ticket_id, attributes)
        result[0].shift
        result[0].collect do |comment|
          self.new(result[1], index_of(result[1].versions, comment)) if !comment.body.blank?
        end.compact
      end

      # The Array#index method doesn't work for the versions...
      # because it seems they're all equal.
      def self.index_of(versions, needle)
        result = nil
        versions.each_with_index do |version, index|
          result = index if version.attributes == needle.attributes
        end
        result
      end

      def self.create(*options)
        attributes = options.first
        ticket_id = attributes.delete(:ticket_id) || attributes.delete('ticket_id')
        project_id = attributes.delete(:project_id) || attributes.delete('project_id')
        ticket = self::API.find(ticket_id, :params => {:project_id => project_id})
        attributes.each do |k, v|
          ticket.send("#{k}=", v)
        end
        versions = ticket.attributes.delete('versions')
        ticket.save
        ticket.attributes['versions'] = versions
        self.find_by_id project_id, ticket_id, ticket.versions.length
      end

      def initialize(ticket, id)
        @system_data ||= {}
        return super(ticket) unless ticket.respond_to?('versions') and ticket.versions.respond_to?('[]')
        @system_data[:ticket] = @system_data[:client] = ticket
        @system_data[:version] = ticket.versions[id] 
        self.project_id = ticket.prefix_options[:project_id] 
        self.id = id
        super(@system_data[:version].attributes) 
      end

      # A custom searcher
      #
      # It returns a custom result because we need the original ticket to make a comment.
      def self.search(project_id, ticket_id, options = {}, limit = 1000)
        ticket = API.find(ticket_id, :params => {:project_id => project_id})
        comments = ticket.versions
        [search_by_attribute(comments, options, limit), ticket]
      end

      # The author's name
      def author
        user_name
      end

    end
  end
end
