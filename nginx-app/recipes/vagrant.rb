if !node[:deploy]
  node[:deploy]    = {}
end

if !node[:deploy][:deploy_to]
  node[:deploy][:deploy_to] = "/var/www/easybib"
end

Chef::Log.debug("deploy: #{node[:deploy][:deploy_to]}")

if !node[:docroot]
  node[:docroot] = 'www'
end

vagrant_dir = "/vagrant_data"

directory "#{node[:deploy][:deploy_to]}" do
  mode      "0755"
  action    :create
  recursive true
end

link "#{node[:deploy][:deploy_to]}/current" do
  to "#{vagrant_dir}"
end

template "/etc/nginx/sites-enabled/easybib.com.conf" do
  source "easybib.com.conf.erb"
  mode   "0755"
  owner  node["nginx-app"][:user]
  group  node["nginx-app"][:group]
  variables(
    :js_alias    => node["nginx-app"][:js_modules],
    :img_alias   => node["nginx-app"][:img_modules],
    :css_alias   => node["nginx-app"][:css_modules],
    :deploy      => node[:deploy],
    :application => "easybib",
    :access_log  => 'off',
    :nginx_extra => 'sendfile  off;'
  )
  notifies :restart, resources(:service => "nginx"), :delayed
end
