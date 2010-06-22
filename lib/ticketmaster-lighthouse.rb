require File.dirname(__FILE__) + '/lighthouse/lighthouse-api'

%w{ lighthouse ticket project }.each do |f|
  require File.dirname(__FILE__) + '/provider/' + f + '.rb';
end

