require 'spec_helper_acceptance'

describe 'cassandra class' do
  pre_req_install_pp = <<-EOS
    include '::cassandra::datastax_repo'
    include '::cassandra::java'
  EOS

  describe 'Pre-requisits installation.' do
    it 'should work with no errors' do
      apply_manifest(pre_req_install_pp, catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(pre_req_install_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end

  cassandra_install_pp = <<-EOS
    if $::osfamily == 'RedHat' and $::operatingsystemmajrelease == 7 {
        $service_systemd = true
    } elsif $::operatingsystem == 'Debian' and $::operatingsystemmajrelease == 8 {
        $service_systemd = true
    } else {
        $service_systemd = false
    }

    if $::osfamily == 'RedHat' {
        $version = '2.2.4-1'
    } else {
        $version = '2.2.4'
    }

    file { '/var/lib/cassandra':
      ensure => directory,
    } ->
    file { '/var/lib/cassandra/commitlog':
      ensure => directory,
    } ->
    file { '/var/lib/cassandra/caches':
      ensure => directory,
    } ->
    file { '/var/lib/cassandra/data':
      ensure => directory,
    } ->
    class { 'cassandra':
      package_ensure              => $version,
      cassandra_9822              => true,
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      saved_caches_directory_mode => '0770',
      service_systemd             => $service_systemd
    } ->
    class { 'cassandra::optutils':
      ensure => $version,
    } ->
    class { '::cassandra::datastax_agent':
        service_systemd => $service_systemd
    } ->
    class { '::cassandra::opscenter::pycrypto':
      manage_epel => true,
    } ->
    class { '::cassandra::opscenter':
      config_purge => true
    }

    cassandra::opscenter::cluster_name { 'Cluster1':
      cassandra_seed_hosts       => 'host1,host2',
    }
  EOS

  describe 'Cassandra installation.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_install_pp, catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(cassandra_install_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end

  firewall_config_pp = <<-EOS
    class { 'cassandra':
      cassandra_9822              => true,
      commitlog_directory_mode    => '0770',
      data_file_directories_mode  => '0770',
      saved_caches_directory_mode => '0770',
    }

    include '::cassandra::optutils'
    include '::cassandra::datastax_agent'
    include '::cassandra::opscenter'
    include '::cassandra::opscenter::pycrypto'

    # This really sucks but Docker, CentOS 6 and iptables don't play nicely
    # together.  Therefore we can't test the firewall on this platform :-(
    if $::operatingsystem != CentOS and $::operatingsystemmajrelease != 6 {
      include '::cassandra::firewall_ports'
    }
  EOS

  describe 'Firewall configuration.' do
    it 'should work with no errors' do
      apply_manifest(firewall_config_pp, catch_failures: true)
    end
  end

  describe service('cassandra') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end

  describe service('datastax-agent') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end

  describe service('opscenterd') do
    it { is_expected.to be_running }
    it { is_expected.to be_enabled }
  end

  interface_config_pp = <<-EOS
    class { 'cassandra':
      listen_interface => 'lo',
      rpc_interface    => 'lo'
    }
  EOS

  describe 'Ensure that the interface can be specified.' do
    it 'should work with no errors' do
      apply_manifest(interface_config_pp, catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(interface_config_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end

  check_against_previous_version_pp = <<-EOS
    include cassandra
  EOS

  describe 'Ensure config file does get updated unnecessarily.' do
    it 'Initial install manifest again' do
      apply_manifest(check_against_previous_version_pp,
                     catch_failures: true)
    end
    it 'Copy the current module to the side without error.' do
      shell('cp -R /etc/puppet/modules/cassandra /var/tmp',
            acceptable_exit_codes: 0)
    end
    it 'Remove the current module without error.' do
      shell('puppet module uninstall locp-cassandra',
            acceptable_exit_codes: 0)
    end
    it 'Install the latest module from the forge.' do
      shell('puppet module install locp-cassandra',
            acceptable_exit_codes: 0)
    end
    it 'Check install works without changes with previous module version.' do
      expect(apply_manifest(check_against_previous_version_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end
end
