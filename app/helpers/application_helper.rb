module ApplicationHelper

  # http://stackoverflow.com/a/8552816/649555
  def cp(path)
    CURRENT if current_page?(path)
  end

  CURRENT = 'current'.freeze

  def icon(icon_link)
    "<i class=\"fa fa-#{icon_link}\"></i>".html_safe
  end

  def flash_class(level)
    case level
        when :notice then "alert alert-info"
        when :success then "alert alert-success"
        when :error then "alert alert-error"
        when :alert then "alert alert-error"
    end
  end
end
