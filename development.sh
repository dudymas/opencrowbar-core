#!/bin/bash
# Copyright 2014, Dell
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
date 
export RAILS_ENV=development

# use the host proxy 
if [[ $http_proxy ]] && ! pidof squid; then
    export upstream_proxy=$http_proxy
fi

# developers may not want TMUX, give them a hint
if [[ $TMUX ]]; then
  echo 'Using TMUX > "export TMUX=false" to disable.'
fi

# setup & load env info
. ./bootstrap.sh 

# install the database
chef-solo -c /opt/opencrowbar/core/bootstrap/chef-solo.rb -o "${database_recipes}"

./setup/01-crowbar-rake-tasks.install && \
    ./setup/02-make-machine-key.install || {
    echo "Failed to bootstrap the Crowbar UI"
    exit 1
}

. /etc/profile
/bin/bash -i
