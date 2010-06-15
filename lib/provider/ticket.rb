module TicketMasterMod
  module Lighthouse
    class Ticket
      # This is an exhaustive list, but should contain the most common ones, add as necessary
      @@allowed_attributes = ["number", "permalink", "milestone_id", "created_at", "title", "closed", "updated_at", "raw_data", "priority", "tag", "url", "attachments_count", "creator_id", "milestone_due_on", "original_body_html", "user_id", "user_name", "original_body", "latest_body", "assigned_user_id", "creator_name", "state"]
      def self.create(ticket)
        ticket_attr = ticket.to_hash.delete_if { |k, v| !@@allowed_attributes.include?(k) }
        project = ticket.project.system_data[:project]
        new_ticket = LighthouseAPI::Ticket.new(:project_id => ticket.project.id)
        ticket_attr.each do |k, v|
          new_ticket.send(k + '=', v)
        end
        new_ticket.save
      end

      def self.save(ticket)
        ticket_attr = ticket.to_hash.delete_if { |k, v| !@@allowed_attributes.include?(k) || ticket.system_data[:ticket].send(k) == v }
        project = ticket.project.system_data[:project]
        lh_ticket = ticket.system_data[:ticket]
        ticket_attr.each do |k, v|
          lh_ticket.send(k + '=', v)
        end
        lh_ticket.save
      end

      def self.close(ticket, resolution)
        project = ticket.project.system_data[:project]
        ticket = LighthouseAPI::Ticket.find(ticket.id, :params => {:project_id => ticket.project.id})
        ticket.state = resolution
        ticket.save
      end
    end
  end
end
