require File.join(File.dirname(__FILE__), 'unit_test_helper')

class NetStub
  
  attr_accessor :last_uri

  def get_response(uri)
    @last_uri = uri
    contents = File.open('test/fixtures/cctray.xml', 'rb') { |f| f.read }
    def contents.body
      self
    end
    contents
  end

end

class CruiseStatusTest < Test::Unit::TestCase
  
  FIXTURE = 'sample'
  DUMMY_URI = 'http://localhost/cctray.xml'
  WORKING_STAGE = "jbehave-monitoring :: defaultStage"
  FAILING_STAGE = "sauron :: defaultStage"
  
  def test_reports_success
    cruise_status = create_cruise_status("false", WORKING_STAGE)
    result = cruise_status.execute
    assert_match(/has status of Success/, result)
  end

  def test_reports_failure
    cruise_status = create_cruise_status("false", FAILING_STAGE)
    result = cruise_status.execute
    assert_match(/has status of Failure/, result)
  end

  def test_no_script
    cruise_status = create_cruise_status("false", WORKING_STAGE)
    result = cruise_status.execute
    assert_no_match(/<script/, result)
  end  
  
  def test_script_present
    cruise_status = create_cruise_status("true", WORKING_STAGE)
    result = cruise_status.execute
    assert_match(/<script/, result)
  end

  def test_green_for_success
    cruise_status = create_cruise_status("true", WORKING_STAGE)
    result = cruise_status.execute
    assert_match(/#00CC00/, result)
  end
  
  def test_red_for_failure
    cruise_status = create_cruise_status("true", FAILING_STAGE)
    result = cruise_status.execute
    assert_match(/#CC0000/, result)
  end  

  def test_uses_correct_uri
    cruise_status = create_cruise_status("false", WORKING_STAGE)
    cruise_status.execute
    assert_equal(URI.parse(DUMMY_URI), cruise_status.http_connector.last_uri)
  end

  def create_cruise_status(change_colour, stage)
    cruise_status = CruiseStatus.new({"cctray" => DUMMY_URI, "stage" => stage, "change-colour" => change_colour}, project(FIXTURE), nil)
    cruise_status.http_connector = NetStub.new
    cruise_status
  end
end
