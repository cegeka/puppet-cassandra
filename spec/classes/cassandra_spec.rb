require 'spec_helper'
describe 'cassandra' do
  let(:pre_condition) do
    [
      'class apt () {}',
      'class apt::update () {}',
      'define apt::key ($id, $source) {}',
      'define apt::source ($location, $comment, $release, $include) {}',
      'define ini_setting($ensure = nil,
         $path,
         $section,
         $key_val_separator       = nil,
         $setting,
         $value                   = nil) {}'
    ]
  end

  let!(:stdlib_stubs) do
    MockFunction.new('concat') do |f|
      f.stubbed.with([], '')
       .returns([''])
      f.stubbed.with([], '/etc/cassandra')
       .returns(['/etc/cassandra'])
      f.stubbed.with([], '/etc/cassandra/default.conf')
       .returns(['/etc/cassandra/default.conf'])
      f.stubbed.with(['/etc/cassandra'], '/etc/cassandra/default.conf')
       .returns(['/etc/cassandra', '/etc/cassandra/default.conf'])
    end
    MockFunction.new('strftime') do |f|
      f.stubbed.with('/var/lib/cassandra-%F')
       .returns('/var/lib/cassandra-YYYY-MM-DD')
    end
  end

  context 'On an unknown OS with defaults for all parameters' do
    let :facts do
      {
        osfamily: 'Darwin'
      }
    end

    it { should raise_error(Puppet::Error) }
  end

  context 'Test the default parameters' do
    let :facts do
      {
        osfamily: 'RedHat'
      }
    end

    it do
      should contain_file('/etc/cassandra/default.conf/cassandra.yaml')
      should contain_class('cassandra').only_with(
        'cassandra_2356_sleep_seconds' => 5,
        'cassandra_9822' => false,
        'cassandra_yaml_tmpl' => 'cassandra/cassandra.yaml.erb',
        'commitlog_directory' => '/var/lib/cassandra/commitlog',
        'commitlog_directory_mode' => '0750',
        'config_file_mode' => '0644',
        'config_path' => '/etc/cassandra/default.conf',
        'config_path_parents' => ['/etc/cassandra'],
        'data_file_directories' => ['/var/lib/cassandra/data'],
        'data_file_directories_mode' => '0750',
        'dc' => 'DC1',
        'dc_suffix' => nil,
        'fail_on_non_supported_os' => true,
        'native_transport_port' => 9042,
        'package_ensure' => 'present',
        'package_name' => 'cassandra22',
        'rack' => 'RAC1',
        'rackdc_tmpl' => 'cassandra/cassandra-rackdc.properties.erb',
        'rpc_address' => 'localhost',
        'saved_caches_directory' => '/var/lib/cassandra/saved_caches',
        'saved_caches_directory_mode' => '0750',
        'service_enable' => true,
        'service_ensure' => 'running',
        'service_name' => 'cassandra',
        'service_provider' => nil,
        'service_refresh' => true,
        'service_systemd' => false,
        'service_systemd_tmpl' => 'cassandra/cassandra.service.erb',
        'settings' => {}
      )
    end

    it do
      should contain_cassandra__private__data_directory('/var/lib/cassandra/data')
    end
  end

  context 'On an unsupported OS pleading tolerance' do
    let :facts do
      {
        osfamily: 'Darwin'
      }
    end
    let :params do
      {
        config_file_mode: '0755',
        config_path: '/etc/cassandra',
        fail_on_non_supported_os: false,
        package_name: 'cassandra',
        service_provider: 'base'
      }
    end

    it do
      should contain_file('/etc/cassandra/cassandra.yaml')
        .with('mode' => '0755')
    end

    it do
      should contain_service('cassandra').with(provider: 'base')
    end

    it { should have_resource_count(9) }
  end

  context 'Ensure cassandra service can be stopped and disabled.' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    let :params do
      {
        service_ensure: 'stopped',
        service_enable: 'false'
      }
    end
    it do
      should contain_service('cassandra')
        .with('ensure' => 'stopped',
              'name'      => 'cassandra',
              'enable'    => 'false')
    end
  end
end
