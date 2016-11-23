require 'spec_helper'
describe 'luks' do
  context 'with default values for all parameters' do
    it { should contain_class('luks') }
  end
end
