default[:duplicity][:cloudfiles][:bucket] = "backup_#{node[:fqdn]}"
default[:duplicity][:s3][:bucket] = "backup_#{node[:fqdn]}"

default[:duplicity][:full_backups_to_keep] = 3

