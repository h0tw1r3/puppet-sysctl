require 'spec_helper'

describe 'sysctl' do
  it { is_expected.to create_class('sysctl') }
  it { is_expected.to contain_file('/etc/sysctl.d') }
end
