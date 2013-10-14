module ApplicationHelper
  # True if parms[:action] = tabName
  def active_action?(actionName)
    params[:action].to_s == actionName
  end
  
  def remote_hostname
    Resolv.getname(request.remote_ip)
  end
end
