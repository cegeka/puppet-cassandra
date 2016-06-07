require 'spec_helper_acceptance'

describe 'cassandra class' do
  schema_testing_drop_type_pp = <<-EOS
    if $::osfamily == 'RedHat' {
        $cassandra_optutils_package = 'cassandra22-tools'
        $cassandra_package = 'cassandra22'
        $version = '2.2.5-1'
    } else {
        $cassandra_optutils_package = 'cassandra-tools'
        $cassandra_package = 'cassandra'
        $version = '2.2.5'
    }

    class { 'cassandra':
      cassandra_9822              => true,
      dc                          => 'LON',
      package_ensure              => $version,
      package_name                => $cassandra_package,
      rack                        => 'R101',
      settings                    => {
        'authenticator'               => 'PasswordAuthenticator',
        'cluster_name'                => 'MyCassandraCluster',
        'commitlog_directory'         => '/var/lib/cassandra/commitlog',
        'commitlog_sync'              => 'periodic',
        'commitlog_sync_period_in_ms' => 10000,
        'data_file_directories'       => ['/var/lib/cassandra/data'],
        'endpoint_snitch'             => 'GossipingPropertyFileSnitch',
        'listen_address'              => $::ipaddress,
        'partitioner'                 => 'org.apache.cassandra.dht.Murmur3Partitioner',
        'saved_caches_directory'      => '/var/lib/cassandra/saved_caches',
        'seed_provider'               => [
          {
            'class_name' => 'org.apache.cassandra.locator.SimpleSeedProvider',
            'parameters' => [
              {
                'seeds' => $::ipaddress,
              },
            ],
          },
        ],
        'start_native_transport'      => true,
      },
    }

    $cql_types = {
      'fullname' => {
        'keyspace' => 'mykeyspace',
        'ensure'   => 'absent'
      }
    }

    if $::operatingsystem != CentOS {
      $os_ok = true
    } else {
      if $::operatingsystemmajrelease != 6 {
        $os_ok = true
      } else {
        $os_ok = false
      }
    }

    if $os_ok {
      class { 'cassandra::schema':
        cql_types      => $cql_types,
        cqlsh_host     => $::ipaddress,
        cqlsh_user     => 'akers',
        cqlsh_password => 'Niner2',
      }
    }
  EOS

  describe '########### Schema drop type.' do
    it 'should work with no errors' do
      apply_manifest(schema_testing_drop_type_pp,
                     catch_failures: true)
    end
    it 'check code is idempotent' do
      expect(apply_manifest(schema_testing_drop_type_pp,
                            catch_failures: true).exit_code).to be_zero
    end
  end
end
