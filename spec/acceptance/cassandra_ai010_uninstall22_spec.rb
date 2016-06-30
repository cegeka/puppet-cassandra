require 'spec_helper_acceptance'

describe 'cassandra class' do
  cassandra_uninstall22_pp = <<-EOS
    Exec {
      path => [
        '/usr/local/bin',
        '/opt/local/bin',
        '/usr/bin',
        '/usr/sbin',
        '/bin',
        '/sbin'],
      logoutput => true,
    }

    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra22-tools'
        $cassandra_package = 'cassandra22'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
    }

    package { $cassandra_optutils_package:
      ensure => absent
    } ->
    package { $cassandra_package:
      ensure => absent
    } ->
    exec { 'rm -rf /var/lib/cassandra/*/*': }
  EOS

  describe '########### Uninstall Cassandra 2.2.' do
    it 'should work with no errors' do
      apply_manifest(cassandra_uninstall22_pp, catch_failures: true)
    end
  end
end
