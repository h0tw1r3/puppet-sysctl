require 'spec_helper'

describe 'sysctl::variable' do
  title = 'net.ipv4.ip_forward'
  let(:pre_condition) { 'include sysctl' }
  let(:title) { title }

  context 'present' do
    let(:params) { { ensure: '1' } }

    it { is_expected.to contain_sysctl__define(title) }
    it do
      is_expected.to contain_file("/etc/sysctl.d/#{title}.conf").with(
        {
          content: "#{title} = 1\n",
          ensure: 'present',
        },
      )
    end

    it { is_expected.to contain_file_line("sysctl-remove-#{title}") }
    it { is_expected.to contain_exec("sysctl-enforce-#{title}") }
  end

  context 'absent' do
    let(:params) { { ensure: 'absent' } }

    it { is_expected.to contain_file("/etc/sysctl.d/#{title}.conf").with_ensure('absent') }
    it { is_expected.to contain_file_line("sysctl-remove-#{title}") }
  end
end
