module ApplicationHelper

  # http://stackoverflow.com/a/8552816/649555
  def cp(path)
    CURRENT if current_page?(path)
  end

  CURRENT = 'current'.freeze
end
