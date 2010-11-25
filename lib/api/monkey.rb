module Lighthouse
  class Project
    def tickets(options = {:limit => 100}) #Give us more results than the default 30
      Ticket.find(:all, :params => options.update(:project_id => id))
    end
  end
end
