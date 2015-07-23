# cassandra
[![Puppet Forge](http://img.shields.io/puppetforge/v/locp/cassandra.svg)](https://forge.puppetlabs.com/locp/cassandra)
[![Github Tag](https://img.shields.io/github/tag/locp/cassandra.svg)](https://github.com/locp/cassandra)
[![Build Status](https://travis-ci.org/locp/cassandra.png?branch=master)](https://travis-ci.org/locp/cassandra)
[![Coverage Status](https://coveralls.io/repos/locp/cassandra/badge.svg?branch=master&service=github)](https://coveralls.io/github/locp/cassandra?branch=master)
[![Join the chat at https://gitter.im/locp/cassandra](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/locp/cassandra?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

#### Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with cassandra](#setup)
    * [What cassandra affects](#what-cassandra-affects)
    * [Beginning with cassandra](#beginning-with-cassandra)
    * [Upgrading](#upgrading)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [cassandra](#class-cassandra)
    * [cassandra::datastax_agent](#class-cassandradatastax_agent)
    * [cassandra::java](#class-cassandrajava)
    * [cassandra::opscenter](#class-cassandraopscenter)
    * [cassandra::opscenter::pycrypto](#class-cassandraopscenterpycrypto)
    * [cassandra::optutils](#class-cassandraoptutils)
    * [cassandra::opscenter::setting](#defined-type-cassandraopscentersetting)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Contributers](#contributers)

## Overview

A Puppet module to install and manage Cassandra and DataStax Agent.

## Setup

### What the cassandra module affects

#### What the cassandra class affects

* Installs the Cassandra package (default **dsc21**).
* Configures settings in *${config_path}/cassandra.yaml*.
* Optionally ensures that the Cassandra service is enabled and running.
* Optionally configures a Yum repository to install the Cassandra packages
  from (on Red Hat).
* Optionally configures an Apt repository to install the Cassandra packages
  from (on Ubuntu).

#### What the cassandra::datastax_agent class affects

* Optionally installs the DataStax agent.

#### What the cassandra::java class affects

* Optionally installs a JRE/JDK package (e.g. java-1.7.0-openjdk).

#### What the cassandra::opscenter class affects

* Installs the opscenter package.
* Manages the content of the configuration file
  (/etc/opscenter/opscenterd.conf).
* Manages the opscenterd service.

#### What the cassandra::opscenter::pycrypto class affects

* On the Red Hat family it installs the pycrypto library and it's
  pre-requisits (the python-devel and python-pip packages).
* Optionally installs the Extra Packages for Enterprise Linux (EPEL)
  repository.

#### What the cassandra::optutils class affects

* Optionally installs the Cassandra support tools (e.g. cassandra21-tools).

### Beginning with cassandra

This most basic example would attempt to install the default Cassandra package
(assuming there is an available repository).  See the *Usage*(#usage) section
for more realistic scenarios.

```puppet
node 'example' {
  include '::cassandra'
}
```

To install the DataStax agent, include the specific class.

```puppet
node 'example' {
  include '::cassandra'
  include '::cassandra::datastax_agent'
}
```

To install with a reasonably sensible Java environment include the java
subclass.

```puppet
node 'example' {
  include '::cassandra'
  include '::cassandra::java'
}
```

To install Cassandra with the optional utilities.

```puppet
node 'example' {
  include '::cassandra'
  include '::cassandra::optutils'
}
```

To install the main cassandra package (which is mandatory) and all the
optional packages, do the following:

```puppet
node 'example' {
  include '::cassandra'
  include '::cassandra::datastax_agent'
  include '::cassandra::java'
  include '::cassandra::optutils'
}
```

By saying the cassandra class/package is mandatory, what is meant is that all
the sub classes have a dependency on the main class.  So for example one
could not specify the cassandra::java class for a node with the cassandra
class also being included.

### Upgrading

The following changes to the API have taken place.

#### Changes in 0.4.0

There is now a cassandra::datastax_agent class, therefore:

* cassandra::datastax_agent_package_ensure has now been replaced with
  cassandra::datastax_agent::package_ensure.
* cassandra::datastax_agent_service_enable has now been replaced with
  cassandra::datastax_agent::service_enable.
* cassandra::datastax_agent_service_ensure has now been replaced with
  cassandra::datastax_agent::service_ensure.
* cassandra::datastax_agent_package_name has now been replaced with
  cassandra::datastax_agent::package_name.
* cassandra::datastax_agent_service_name has now been replaced with
  cassandra::datastax_agent::service_name.

Likewise now there is a new class for handling the installation of Java:

* cassandra::java_package_ensure has now been replaced with
  cassandra::java::ensure.
* cassandra::java_package_name has now been replaced with
  cassandra::java::package_name.

Also there is now a class for installing the optional utilities:

* cassandra::cassandra_opt_package_ensure has now been replaced with
  cassandra::optutils:ensure.
* cassandra::cassandra_opt_package_name has now been replaced with
  cassandra::optutils:package_name.

#### Changes in 0.3.0

* cassandra_opt_package_ensure changed from 'present' to undef.

* The manage_service option has been replaced with service_enable and
  service_ensure.

## Usage

### Create a Small Cluster

To install Cassandra in a two node cluster called 'Foobar Cluster' where
node1 (192.168.42.1) is the seed and node2 (192.168.42.2) is also to be a
member, do something similar to this:

```puppet
include cassandra::java
include cassandra::optutils

node 'node1' {
  class { 'cassandra':
    cluster_name    => 'Foobar Cluster',
    listen_address  => "${::ipaddress}",
    seeds           => "${::ipaddress}",
    manage_dsc_repo => true
  }
}

node 'node2' {
  class { 'cassandra':
    cluster_name    => 'Foobar Cluster',
    listen_address  => "${::ipaddress}",
    seeds           => '192.168.42.1',
    manage_dsc_repo => true
  }
}
```

This would also ensure that the JDK is installed and the optional Cassandra
tools.

## Reference

### Public Classes

* **cassandra**
* **cassandra::datastax_agent**
* **cassandra::java**
* **cassandra::opscenter**
* **cassandra::opscenter::pycrypto**
* **cassandra::optutils**

### Defined Types

* **cassandra::opscenter::setting**

### Class: cassandra

A class for installing the Cassandra package and manipulate settings in the
configuration file.

#### Parameters

##### `authenticator`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **AllowAllAuthenticator**).

##### `authorizer`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default: **AllowAllAuthorizer**).

##### `auto_snapshot`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **true**).

##### `cassandra_package_ensure`
The status of the package specified in **cassandra_package_name**.  Can be
*present*, *latest* or a specific version number (default **present**).

##### `cassandra_package_name`
The name of the Cassandra package.  Must be available from a repository
(default **dsc21**).

##### `cassandra_yaml_tmpl`
The path to the Puppet template for the Cassandra configuration file.  This
allows the user to supply their own customized template.  A Cassandra 1.X
compatible template called cassandra1.yaml.erb has been provided by @Spredzy
(default **cassandra/cassandra.yaml.erb**).

##### `client_encryption_enabled`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **false**).

##### `client_encryption_keystore`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **conf/.keystore**).

##### `client_encryption_keystore_password`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **cassandra**).

##### `cluster_name`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **Test Cluster**).

##### `commitlog_directory`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **/var/lib/cassandra/commitlog**).

##### `concurrent_counter_writes`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **32**).

##### `concurrent_reads`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **32**).

##### `concurrent_writes`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **32**).

##### `config_path`
The path to the cassandra configuration file.  If this is undef, it will be
changed to **/etc/cassandra/default.conf** on the Red Hat family of operating
systems or **/etc/cassandra** on Ubuntu.  Otherwise the user can specify the
path name
(default **undef**).

##### `data_file_directories`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **['/var/lib/cassandra/data']**).

##### `disk_failure_policy`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default: **stop**).

##### `endpoint_snitch`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default: **SimpleSnitch**).

##### `hinted_handoff_enabled`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(defaults to **'true'**).

##### `incremental_backups`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **false**).

##### `internode_compression`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **all**).

##### `listen_address`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **localhost**).

##### `manage_dsc_repo`
If set to true then a repository will be setup so that packages can be
downloaded from the DataStax community edition (default **false**).

##### `native_transport_port`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **9042**).

##### `num_tokens`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **256**).

##### `partitioner`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **org.apache.cassandra.dht.Murmur3Partitioner**)

##### `rpc_address`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **localhost**).

##### `rpc_port`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **9160**).

##### `rpc_server_type`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **sync**).

##### `saved_caches_directory`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **/var/lib/cassandra/saved_caches**).

##### `seeds`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **127.0.0.1**).

##### `server_encryption_internode`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **none**).

##### `server_encryption_keystore`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **conf/.keystore**).

##### `server_encryption_keystore_password`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **cassandra**).

##### `server_encryption_truststore`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **conf/.truststore**).

##### `server_encryption_truststore_password`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **cassandra**).

##### `service_enable`
Enable the Cassandra service to start at boot time.  Valid values are true
or false
(default: **true**)

##### `service_ensure`
Ensure the Cassandra service is running.  Valid values are running or stopped
(default: **running**)

##### `service_name`
The name of the service that runs the Cassandra software (default
**cassandra**).

##### `snapshot_before_compaction`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **false**).

##### `start_native_transport`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **true**).

##### `start_rpc`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **true**).

##### `storage_port`
This is passed to the
[cassandra.yaml](http://docs.datastax.com/en/cassandra/2.1/cassandra/configuration/configCassandra_yaml_r.html) file
(default **7000**).

### Class: cassandra::datastax_agent

A class for installing the DataStax agent and to point it at an OpsCenter
instance.

#### Parameters

##### `package_ensure`
Is passed to the package reference.  Valid values are **present** or a version
number
(default **present**).

##### `package_name`
Is passed to the package reference (default **datastax-agent**).

##### `service_ensure`
Is passed to the service reference (default **running**).

##### `service_enable`
Is passed to the service reference (default **true**).

##### `service_name`
Is passed to the service reference (default **datastax-agent**).

##### `stomp_interface`
If the value is changed from the default of *undef* then this is what is
set as the stomp_interface setting in
**/var/lib/datastax-agent/conf/address.yaml**
which connects the agent to an OpsCenter instance
(default **undef**).

### Class: cassandra::java

A class to install a reasonably sensible Java package.

#### Parameters

##### `ensure`
Is passed to the package reference.  Valid values are **present** or a version
number
(default **present**).

##### `package_name`
If the default value of *undef* is left as it is, then a package called
java-1.8.0-openjdk-headless or openjdk-7-jre-headless will be installed
on a Red Hat family or Ubuntu system respectively.  Alternatively, one
can specify a package that is available in a package repository to the
node
(default **undef**).

### Class: cassandra::opscenter

This class installs and manages the DataStax OpsCenter.  For this class, when
a field value is set to *undef*, no attempt is made to set (or remove) the
value from the configuration file.  For example, the **ssl_port** in the
default configuration file that is distributed with packages is commented out.
As the default value for this class is *undef* then no attempt will be made
to edit that value at all.  However, if one was to set the value (to **8443**
for example), that value would be set in the relevant section of the
configuration file.

#### Parameters

##### `ensure`
This is passed to the package reference for **opscenter**.  Valid values are
**present** or a version number
(default **present**).

##### `config_file`
The full path to the OpsCenter configuration file
(default **/etc/opscenter/opscenterd.conf**).

##### `package_name`
The name of the OpsCenter package
(default **opscenter**).

##### `service_enable`
Enable the OpsCenter service to start at boot time.  Valid values are true
or false
(default: **true**)

##### `service_ensure`
Ensure the OpsCenter service is running.  Valid values are running or stopped
(default: **running**)

##### `service_name`
The name of the service that runs the OpsCenter software (default
**opscenterd**).

The rest of the module parameters are passed into the configuration file only
if a default is set or the user specifies a value that is not *undef*.  See
http://docs.datastax.com/en/opscenter/5.2/opsc/configure/opscConfigProps_r.html
for details on a specific parameter.

If a setting is set to *undef* then the module will ensure that the setting is
removed.

Leaving the defaults as they are will provide a running OpsCenter without any
authentication.

This table shows the name of the modle parameter, specifies which section
and setting it is associated with in the configuration file and shows what the
default value is:

Module Parameter            | Section        | Setting | Default Value
--------------------------- | -------------- | ------- | -------------
```authentication_enabled```| authentication | enabled | **False**

### Class: cassandra::opscenter::pycrypto

On the Red Hat family of operating systems, if one intends to use encyption
for configuration values then the pycrypto library is required.  This class
will install it for the user.  See
http://docs.datastax.com/en/opscenter/5.2//opsc/configure/installPycrypto.html
for more details.

This class has no effect when included on nodes that are not in the Red Hat
family.

#### Parameters

##### `ensure`
This is passed to the package reference for **pycrypto**.  Valid values are
**present** or a version number
(default **present**).

##### `manage_epel`
If set to true, the **epel-release** package will be installed
(default **false**).

##### `package_name`
The name of the PyCrypto package
(default **pycrypto**).

##### `provider`
The name of the provider of the pycrypto package
(default **pip**).

##### `reqd_pckgs`
Packages that are required to install the pycrypto package
(default **['python-devel', 'python-pip' ]**).

### Class: cassandra::optutils

A class to install the optional Cassandra tools package.

#### Parameters

##### `ensure`
Is passed to the package reference.  Valid values are **present** or a version
number
(default **present**).

##### `package_name`
If the default value of *undef* is left as it is, then a package called
cassandra21-tools or cassandra-tools will be installed
on a Red Hat family or Ubuntu system respectively.  Alternatively, one
can specify a package that is available in a package repository to the
node
(default **undef**).

### Defined Type cassandra::opscenter::setting

Simply a defined type to be used as a macro for settings in the OpsCenter
configuration file.  This is not really supposed to be used by a user (who
should use the API provided by cassandra::opscenter instead) but is documented
here for completeness.

#### Parameters

##### `service_name`
The name of the service to be notified if a change is made to the
configuration file.  Typically this would by **opscenterd**.

##### `path`
The path to the configuration file.  Typically this would by
**/etc/opscenter/opscenterd.conf**.

##### `section`
The section in the configuration file to be added to (e.g. **webserver**).

##### `setting`
The setting within the section of the configuration file to changed
(e.g. **port**).

##### `value`
The setting value to be changed to (e.g. **8888**).  If this is set to
**unset** then the setting is ignored.  No attempt will be made to remove
a setting even if it is set to **undef**.

## Limitations

Tested on the Red Hat family versions 6 and 7, Ubuntu 12.04 and 14.04, Puppet
(CE) 3.7.5 and DSC 2.1.

## Contributers

Contributions will be gratefully accepted.  Please go to the project page,
fork the project, make your changes locally and then raise a pull request.
Details on how to do this are available at
https://guides.github.com/activities/contributing-to-open-source.

### Additional Contributers

* Yanis Guenane (GitHub [@spredzy](https://github.com/Spredzy)) provided the
Cassandra 1.x compatible template
(see [#11](https://github.com/locp/cassandra/pull/11)).

* Amos Shapira (GitHub [@amosshapira](https://github.com/amosshapira)) fixed
a bug in the requirements metadata that caused a problem with Puppetfile
(see [#34](https://github.com/locp/cassandra/pull/34)).
