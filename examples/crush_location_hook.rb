#!/usr/bin/env ruby2.3

require 'yaml'

# VARIABLES/CONSTANTS
CONFIG_FILE='/etc/ceph/osd_crush_locations'

cluster_name=ARGV[1]
osd_id=ARGV[3]
type=ARGV[5] # currently not used

# FUNCTIONS
def matches?(mounted_device,path)
  raw_path=`readlink -f #{path}`.chomp
  match_path=raw_path
  if File.stat(raw_path).blockdev? and not raw_path =~ /[0-9]+$/
    # looks like a whole block device is given, so we need to check
    # the first partition on it
    match_path = raw_path + '1'
  end
  return mounted_device.to_s == match_path.to_s
end

# MAIN
mounted_device=`cat /proc/mounts | grep "#{cluster_name}-#{osd_id} " | awk '{print $1}'`.chomp
if not mounted_device
  STDERR.puts "Could not find device for osd with id #{osd_id}"
end

# lets read our definitions file and compare
definitions=YAML.load_file(CONFIG_FILE)
definitions.keys.each do |device|
  if matches?(mounted_device,device)
    puts definitions[device]
  end
end
