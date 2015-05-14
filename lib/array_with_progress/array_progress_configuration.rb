require 'highline/system_extensions'

class ArrayProgressConfiguration
  def self.terminal_width
    HighLine::SystemExtensions.terminal_size[0]
  end

  def self.item_width
    terminal_width - 22
  end
end
