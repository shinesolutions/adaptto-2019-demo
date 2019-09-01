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

Puppet::Type.newtype(:aem_authorizable_keystore) do
  ensurable do
    newvalue(:archived) do
      provider.archive
    end

    newvalue(:present) do
      if @resource.provider&.respond_to?(:create)
        @resource.provider.create
      else
        @resource.create
      end
      nil
    end

    newvalue(:exists) do
      if @resource.provider&.respond_to?(:exists?)
        @resource.provider.exists?
      else
        @resource.exists?
      end
      nil
    end

    newvalue(:absent) do
      if @resource.provider&.respond_to?(:destroy)
        @resource.provider.destroy
      else
        @resource.destroy
      end
      nil
    end
  end

  def self.title_patterns
    [[/^(.*)$/, [[:name, ->(x) { x }]]]]
  end

  newparam :name do
    isnamevar
    desc 'Description'
  end

  newparam :aem_id do
    isnamevar
    desc 'AEM instance ID'
  end

  newparam :aem_username do
    desc 'AEM username'
  end

  newparam :aem_password do
    desc 'AEM password'
  end

  newparam :authorizable_id do
    desc 'Authorizable user id'
    validate do |value|
      raise ArgumentError.new('authorizable_id must be provided') if value == ''
    end
  end

  newparam :file do
    desc 'Full path to the Keystore file store.p12.'
    validate do |value|
      value = nil if value == ''
    end
  end

  newparam :force do
    desc 'Force creation of the Keystore via File'
    validate do |value|
      value = false if value == ''
    end
  end

  newparam :intermediate_path do
    desc 'User Home Path'
    validate do |value|
      raise ArgumentError.new('intermediate_path must be provided') if value == ''
    end
  end

  newparam :password do
    desc 'Password of the Keystore.'
  end

  newparam :path do
    desc 'Directory path to archive the Keystore file store.p12. '
    validate do |value|
      value = nil if value == ''
    end
  end

  newparam :retries_max_tries do
    desc 'Maximum tries when waiting for package to be uploaded/installed'
    validate do |value|
      value = 30 if value == ''
    end
  end

  newparam :retries_base_sleep_seconds do
    desc 'Starting wait delay in seconds when waiting for package to be uploaded/installed'
    validate do |value|
      value = 2 if value == ''
    end
  end

  newparam :retries_max_sleep_seconds do
    desc 'Maximum wait delay in seconds when waiting for package to be uploaded/installed'
    validate do |value|
      value = 2 if value == ''
    end
  end
end
