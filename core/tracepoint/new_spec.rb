require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

ruby_version_is '2.0' do
  describe 'TracePoint.new' do
    it 'returns a new TracePoint object, not enabled by default' do
      TracePoint.new(:call) {}.enabled?.should be_false
    end

    it 'includes :line event when event is not specified' do
      event_name = nil
      TracePoint.new() { |tp| event_name = tp.event }.enable do
        event_name.should equal(:line)

        event_name = nil
        test
        event_name.should equal(:line)

        event_name = nil
        TracePointSpec::B.new.foo
        event_name.should equal(:line)
      end
    end

    it 'converts given event name as string into symbol using to_sym' do
      event_name = nil
      (o = mock('return')).should_receive(:to_sym).and_return(:return)

      TracePoint.new(o) { |tp| event_name = tp.event}.enable do
        event_name.should equal(nil)
        test
        event_name.should equal(:return)
      end
    end

    it 'includes multiple events when multiple event names are passed as params' do
      event_name = nil
      TracePoint.new(:end, :call) do |tp|
        event_name = tp.event
      end.enable do
        test
        event_name.should equal(:call)

        TracePointSpec::B.new.foo
        event_name.should equal(:call)

        class B; end
        event_name.should equal(:end)
      end
    end

    it 'raises a TypeError when the given object is not a string/symbol' do
      o = mock('123')
      -> { TracePoint.new(o) {}}.should raise_error(TypeError)

      o.should_receive(:to_sym).and_return(123)
      -> { TracePoint.new(o) {}}.should raise_error(TypeError)
    end

    it 'expects to be called with a block' do
      begin
        TracePoint.new(:line)
      rescue => e
        e.class.should equal(ThreadError)
        e.message.should == 'must be called with a block'
      end
    end

    it "raises a Argument error when the give argument doesn't match an event name" do
      begin
        TracePoint.new(:test)
      rescue => e
        e.class.should equal(ArgumentError)
        e.message.should == 'unknown event: test'
      end
    end
  end
end