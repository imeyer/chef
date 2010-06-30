#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2010 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/knife'
require 'chef/data_bag'
require 'chef/data_bag_item'

class Chef
  class Knife
    class DataBagFromFile < Knife

      banner "Sub-Command: data bag from file BAG FILE (options)"

      def run
        @data_bag_name, @data_bag_item_file = @name_args
        @data_bag_item_name = @data_bag_item_file.split('.')[0]

        if @data_bag_name.nil?
          show_usage
          Chef::Log.fatal("You must specify a data bag name")
          exit 1
        end

        begin
          Chef::DataBagItem.load(@data_bag_name, @data_bag_item_name)
        rescue Net::HTTPServerException => e
          raise unless e.to_s =~ /^404/

          rest.post_rest("data", { "name" => @data_bag_name })
          Chef::Log.info("Created data_bag[#{@data_bag_name}]")
        end

        data_bag_data = load_from_file(Chef::DataBagItem, @data_bag_item_file, @data_bag_name)

        rest.put_rest("data/#{@data_bag_name}/#{@data_bag_item_name}", data_bag_data)

        Chef::Log.info("Updated data_bag_item[#{@data_bag_name}]")
      end
    end
  end
end
