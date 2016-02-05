#!/bin/bash
#############################################################################
# A script for splitting the test suite across nodes on CircleCI.
#############################################################################

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
export PATH=/home/ubuntu/.rvm/gems/ruby-1.9.3-p448/bin:$PATH

acceptance_tests () {
  if [ -z "${RUN_NIGHTLY_BUILD}" ]; then
    echo "Acceptance tests are normally only run as a nightly build."
    exit 0
  fi

  status=0
  i=0
  BEAKER_NODES="centos6 centos7 debian7 ubuntu12.04 ubuntu14.04"

  # We set beaker not to destroy the node because this fails on CircleCI
  # which then marks otherwise successful builds as failures.
  export BEAKER_destroy=off

  for node in $BEAKER_NODES; do
    if [ $(($i % $CIRCLE_NODE_TOTAL)) -eq $CIRCLE_NODE_INDEX ]; then
      BEAKER_set=$node bundle exec rake beaker || status=$?
    fi

    ((i=i+1))
  done

  return $status
}

unit_tests () {
  if [ -z "$RVM"  ]; then
    echo "No unit tests for this node."
    return 0
  fi

  status=0
  rvm use $RVM --install --fuzzy
  export BUNDLE_GEMFILE=$PWD/Gemfile
  rm -f Gemfile.lock
  ruby --version
  rvm --version
  bundle --version
  gem --version
  bundle install --without development
  bundle exec rake lint || status=$?
  bundle exec rake validate || status=$?

  bundle exec rake spec SPEC_OPTS="--format RspecJunitFormatter \
      -o $CIRCLE_TEST_REPORTS/rspec/puppet.xml" || status=$?
  return $status
}

export BEAKER_set=""
export RVM=""

case $CIRCLE_NODE_INDEX in
  0)  export RVM=1.9.3
      export PUPPET_GEM_VERSION="~> 3.0"
      ;;
  1)  export RVM=2.1.5
      export PUPPET_GEM_VERSION="~> 3.0"
      ;;
  2)  export RVM=2.1.6
      export PUPPET_GEM_VERSION="~> 4.0"
      export STRICT_VARIABLES="yes"
      ;;
esac

$1
exit $?
