require 'spec_helper'
describe 'cassandra::optutils' do
  context 'On a RedHat OS with defaults for all parameters' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    it { should have_resource_count(1) }
    it do
      should contain_class('cassandra::optutils').with(
        'ensure'       => 'present',
        'package_name' => nil
      )
    end
    it { should contain_package('cassandra22-tools') }
  end

  context 'On a Debian OS with defaults for all parameters' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    it { should contain_class('cassandra::optutils') }
    it { should contain_package('cassandra-tools') }
  end

  context 'With java_package_name set to foobar' do
    let :params do
      {
        package_name: 'foobar-java',
        ensure: '42'
      }
    end

    it do
      should contain_package('foobar-java').with(
        ensure: 42
      )
    end
  end
end
