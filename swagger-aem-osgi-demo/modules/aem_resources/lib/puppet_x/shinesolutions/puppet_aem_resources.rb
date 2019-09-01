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

require 'ruby_aem'

module PuppetX
  module ShineSolutions
    # Puppet AEM Resources provider
    # This class uses https://github.com/shinesolutions/ruby_aem to interact with AEM
    class PuppetAemResources < Puppet::Provider
      @label = '[puppet-aem-resources]'

      def self.client(opts = nil)
        aem_id = opts[:aem_id] || 'aem'
        config_file = File.join([File.dirname(Puppet.settings[:config]), format('%<aem_id>s.yaml', aem_id: aem_id)])
        config = YAML.load_file(config_file) if File.exist?(config_file)

        # Set RubyAem::Aem parameters in order of priority:
        # - use opts if provided, opts uses field names with `aem_` prefix
        # - otherwise, use environment variable if provided, variable name is prefixed with value of `aem_id` variable,
        #   e.g. if aem_id is aem, then the environment variables would be aem_username, aem_password, aem_debug
        # - otherwise, use config file property if provided, config file name is using `aem_id` variable,
        #   e.g. if aem_id is aem, then file name is aem.yaml
        # - otherwise, use RubyAem::Aem's default configuration values
        params = {}
        %w[username password protocol host port debug timeout verify_ssl].each { |field|
          opt_field = format('aem_%<field>s', field: field)
          env_field = format('%<aem_id>s_%<field>s', aem_id: aem_id, field: field)
          if !opts.nil? && !opts[opt_field.to_sym].nil?
            params[field.to_sym] = opts[opt_field.to_sym]
          elsif !ENV[env_field].nil?
            params[field.to_sym] = ENV[env_field]
          elsif !config.nil? && !config[field.to_sym].nil?
            params[field.to_sym] = config[field.to_sym]
          else
            Puppet.debug("#{@label} AEM #{field} field is not specified, using default value from ruby_aem")
          end
        }

        RubyAem::Aem.new(params)
      end

      def client(resource)
        self.class.client(
          aem_id: resource[:aem_id],
          aem_username: resource[:aem_username],
          aem_password: resource[:aem_password]
        )
      end

      def client_opts(opts = nil)
        self.class.client(opts)
      end

      # Call the object's method with an array of params, which resource must contain retries opts.
      # This wrapper ensures that the readiness check is applied prior to calling the method.
      # This was introduced specifically for handling AEM 6.4 calls which seem to restart resources
      # (e.g. Package Manager Servlet) and requires a longer readiness time than previously observed
      # in AEM 6.2 and 6.3 .
      def call_with_readiness_check(obj, method, params, resource)
        check_opts = {
          _retries: {
            max_tries: resource[:retries_max_tries],
            base_sleep_seconds: resource[:retries_base_sleep_seconds],
            max_sleep_seconds: resource[:retries_max_sleep_seconds]
          }
        }
        client(resource).aem.get_package_manager_servlet_status_wait_until_ready(check_opts)
        obj.send(method, *params)
      end

      def handle(result)
        unless result.response.eql? nil
          Puppet.debug("#{@label} Response status code: #{result.response.status_code}")
          Puppet.debug("#{@label} Response body:\n#{result.response.body[0..500]}") if result.response.body.is_a? String
          Puppet.debug("#{@label} Response headers:\n#{result.response.headers}")
        end
        Puppet.info("#{@label} #{result.message}") unless result.message.eql? nil
      end

      def handle_multi(results)
        results.each { |result| handle(result) }
      end
    end
  end
end
