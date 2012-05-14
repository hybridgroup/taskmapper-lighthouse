module TaskMapper::Provider
  module Lighthouse
    # Project class for taskmapper-lighthouse
    # 
    # 
    class Project < TaskMapper::Provider::Base::Project
      attr_accessor :prefix_options
      API = ::Lighthouse::Project  
      # Delete this project
      def destroy
        result = super
        result.is_a?(Net::HTTPOK)
      end
      
      # copy from this.copy(that) copies that into this
      def copy(project)
        project.tickets.each do |ticket|
          copy_ticket = self.ticket!(:title => ticket.title, :description => ticket.description)
          ticket.comments.each do |comment|
            copy_ticket.comment!(:body => comment.body)
            sleep 1
          end
        end
      end

    end
  end
end
