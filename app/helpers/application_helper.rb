module ApplicationHelper
  # True if parms[:action] = tabName
  def active_action?(actionName)
    params[:action].to_s == actionName
  end
end
