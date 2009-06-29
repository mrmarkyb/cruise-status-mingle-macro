class CruiseStatus
  require 'net/http'
  require 'uri'
  require 'rexml/document'
  include REXML

  attr_accessor :http_connector

  def initialize(parameters, project, current_user)
    @parameters = parameters
    @project = project
    @current_user = current_user
    @http_connector = Net::HTTP
  end
    
  def execute
    status = derive_status
    status_string = " stage #{stage} on #{cctray} has status of #{status}"
    if(change_colour)    
<<-HTML
      #{status_string}
      <script type="text/javascript">
        document.getElementById('hd').style.background = "#{colour(status)}";
        document.getElementById('hd-bottom').style.background = "#{colour(status)}";
      </script>
    HTML
    else
      status_string
    end
  end
  
  def can_be_cached?
    false  # if appropriate, switch to true once you move your macro to production
  end

  def cctray
    @parameters['cctray']
  end

  def stage
    @parameters['stage']
  end

  def change_colour
    @parameters['change-colour'] == "true"
  end

  def derive_status
    cctray_out = @http_connector.get_response(URI.parse(cctray)).body
    doc = REXML::Document.new(cctray_out)
    XPath.first(doc, "/Projects/Project[@name='#{stage}']/@lastBuildStatus").value
  end

  def colour(status)
    if(status == "Success")
      "#00CC00"
    else
      "#CC0000"
    end
  end
    
end

