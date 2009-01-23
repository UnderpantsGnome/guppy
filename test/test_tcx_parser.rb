require 'test/garmin_test_setup'

class TestTcxParser < Test::Unit::TestCase
  context "existance" do
    should "exist" do
      assert Garmin::TcxParser.new('foo.tcx')
    end
  end

  context "opening" do
    should "should create the tcx parser object" do
      flexmock(Garmin::TcxParser).should_receive(:new).with('foo.tcx').and_return(flexmock('parser', :parse => '')).once
      Garmin::TcxParser.open('foo.tcx')
    end

    should "parse the file" do
      parser = flexmock('parser')
      parser.should_receive(:parse).once
      flexmock(Garmin::TcxParser).should_receive(:new).and_return(parser)
      
      Garmin::TcxParser.open('foo.tcx')
    end

    should "return the TcxParser object" do
      parser = flexmock('parser', :parse => '')
      flexmock(Garmin::TcxParser).should_receive(:new).with('foo.tcx').and_return(parser)

      assert_equal parser, Garmin::TcxParser.open('foo.tcx')
    end
  end

  context "parsing" do
    setup do
      @parser = Garmin::TcxParser.new('foo.tcx')
    end
    
    should "open the file" do
      flexmock(File).should_receive(:open).with('foo.tcx').and_return(flexmock('file', :read => '', :close => '')).once

      @parser.parse
    end

    should "read the file" do
      file = flexmock('file', :close => '')
      file.should_receive(:read).once
      
      flexmock(File).should_receive(:open).with('foo.tcx').and_return(file)

      @parser.parse
    end

    should "pass the file data into nokogiri" do
      flexmock(File).should_receive(:open).with('foo.tcx').and_return(flexmock('file', :read => 'xml data', :close => ''))

      flexmock(Nokogiri).should_receive(:XML).with('xml data').once

      @parser.parse
    end

    should "close the file handle" do
      file = flexmock('file', :read => '')
      file.should_receive(:close).once
      
      flexmock(File).should_receive(:open).with('foo.tcx').and_return(file)

      @parser.parse
    end
  end

  context "finding all activities" do
    setup do
      @p = Garmin::TcxParser.new(tcx_fixture_file)
      @p.parse
    end
    
    should "find the activities" do
      assert_equal 1, @p.activities.size
    end

    should "create Activity objects" do
      assert @p.activities.first.is_a?(Garmin::Activity), "Expected an Activity, got a #{@p.activities.first.class}"
    end

    should "give the Activity objects a sport property" do
      assert_equal "Running", @p.activities.first.sport
    end

    should "give the Activity objects a date" do
      assert_equal Time.parse('2009-01-12T19:28:18Z'), @p.activities.first.date
    end

    should "give the Activity objects a distance" do
      assert_equal 1609.3439941, @p.activities.first.distance
    end
  end

  context "finding a specific activity" do
    setup do
      @p = Garmin::TcxParser.new(tcx_fixture_file)
      @p.parse
    end
    
    should "return an activity" do
      assert @p.activity('2009-01-12T19:28:18Z').is_a?(Garmin::Activity)
    end

    should "return nil if the activity was not found" do
      assert_nil @p.activity('2009-01-12T19:27:18Z')
    end

    should "build the activity" do
      flexmock(@p).should_receive(:build_activity).once

      @p.activity('2009-01-12T19:28:18Z')
    end
  end
end
