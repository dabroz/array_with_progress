class ArrayProgressConfiguration
  def self.terminal_width
    `tput cols`.to_i
  rescue Errno::ENOENT => e
    80
  end

  def self.item_width
    terminal_width - 22
  end
end
