require File.expand_path('../../../spec_helper', __FILE__)

ruby_version_is '2.0' do
  describe 'TracePoint#self' do
    it 'return the trace object from event' do
      trace = nil
      TracePoint.new(:line) { |tp| trace = tp.self }.enable do
        trace.equal?(self).should be_true
      end
    end
  end
end