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

Puppet::Type.type(:aem_authorizable_keystore).provide(:aem, parent: PuppetX::ShineSolutions::PuppetAemResources) do
  # Archive a AEM Truststore by downloading in to the specified path.
  def archive
    file_path = resource[:file] if resource[:file]
    file_path = "#{resource[:path]}/store.p12" if resource[:path]
    return false if file_path.nil?

    authorizable_keystore = client(resource).authorizable_keystore(resource[:intermediate_path], resource[:authorizable_id])
    result = authorizable_keystore.download(file_path)

    handle(result)
  end

  # Create the AEM Keystore.
  def create
    authorizable_keystore = client(resource).authorizable_keystore(resource[:intermediate_path], resource[:authorizable_id])
    result = authorizable_keystore.create(resource[:password])

    handle(result)
  end

  # Delete the AEM Keystore.
  def destroy
    authorizable_keystore = client(resource).authorizable_keystore(resource[:intermediate_path], resource[:authorizable_id])
    result = authorizable_keystore.delete

    handle(result)
  end

  # Check if the AEM Keystore exists
  def exists?
    return false if resource[:force].eql? true

    authorizable_keystore = client(resource).authorizable_keystore(resource[:intermediate_path], resource[:authorizable_id])
    result = authorizable_keystore.exists

    result.data
  end
end
