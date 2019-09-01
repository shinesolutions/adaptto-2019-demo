# frozen_string_literal: true

# Copyright 2016-2019 Shine Solutions
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative '../../../puppet_x/shinesolutions/puppet_aem_resources.rb'

Puppet::Type.type(:aem_aem).provide(:aem, parent: PuppetX::ShineSolutions::PuppetAemResources) do
  # Get the login page and wait until it's ready.
  # This is handy when AEM restarts Jetty and the next operation needs to wait.
  def get_login_page_wait_until_ready
    opts = {
      _retries: {
        max_tries: resource[:retries_max_tries],
        base_sleep_seconds: resource[:retries_base_sleep_seconds],
        max_sleep_seconds: resource[:retries_max_sleep_seconds]
      }
    }
    client(resource).aem.get_login_page_wait_until_ready(opts)
  end

  def get_package_manager_servlet_status_wait_until_ready
    opts = {
      _retries: {
        max_tries: resource[:retries_max_tries],
        base_sleep_seconds: resource[:retries_base_sleep_seconds],
        max_sleep_seconds: resource[:retries_max_sleep_seconds]
      }
    }
    client(resource).aem.get_package_manager_servlet_status_wait_until_ready(opts)
  end

  def get_aem_health_check_wait_until_ok
    opts = {
      tags: resource[:tags],
      combine_tags_or: resource[:combine_tags_or],
      _retries: {
        max_tries: resource[:retries_max_tries],
        base_sleep_seconds: resource[:retries_base_sleep_seconds],
        max_sleep_seconds: resource[:retries_max_sleep_seconds]
      }
    }
    client(resource).aem.get_aem_health_check_wait_until_ok(opts)
  end

  # Get the install status and wait until it's finished.
  # This is handy for waiting while AEM is installing one or more packages
  # until they are all finished.
  def get_install_status_wait_until_finished
    opts = {
      _retries: {
        max_tries: resource[:retries_max_tries],
        base_sleep_seconds: resource[:retries_base_sleep_seconds],
        max_sleep_seconds: resource[:retries_max_sleep_seconds]
      }
    }
    client(resource).aem.get_install_status_wait_until_finished(opts)
  end

  def remove_all_agents
    run_modes = resource[:run_mode].nil? ? %w[author publish] : [resource[:run_mode]]

    run_modes.each do |run_mode|
      result = client(resource).aem.get_agents(run_mode)
      agent_names = result.data
      agent_names.each do |agent_name|
        replication_agent = client(resource).replication_agent(run_mode, agent_name)
        call_with_readiness_check(replication_agent, 'delete', [], resource)
      end
    end
  end

  def list_packages_by_groups(package_groups)
    aem = client(resource).aem
    result = call_with_readiness_check(aem, 'get_packages', [], resource)
    packages = result.data
    packages.each do |package|
      next unless (package_groups.include? package['group']) || package_groups.empty?

      puts '========================================================================'
      package.each do |key, value|
        puts "#{key}: #{value}"
      end
    end
  end

  # Existence check defaults to true in order to simulate that aem always exists.
  def exists?
    true
  end
end
