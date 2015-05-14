require 'array_with_progress/array_progress_configuration'
require 'colorize'

class ArrayProgressItem
  attr_accessor :parent
  attr_accessor :item

  attr_accessor :status, :extra_name, :progress, :name

  def self.run!(parent_, item_, progress_, &block)
    pi = ArrayProgressItem.new
    pi.parent = parent_
    pi.item = item_
    pi.progress = sprintf('[%5.1f%%] ', progress_)
    pi.run!(&block)
  end

  def change_name(new_name)
    set_name(new_name)
    reprint!
  end

  def expand_name(extra_name)
    self.extra_name = extra_name
    reprint!
  end

  def run!
    self.status = nil
    self.extra_name = ''
    
    set_name(item)
    reprint!

    self.status = process_status_code(yield(item, self))
    reprint!
    print "\n"
  end

  private

  def process_status_code(code)
    if code.is_a? Symbol
      code
    elsif code.is_a? TrueClass
      :ok
    elsif code.is_a? FalseClass
      :error
    else
      :unknown
    end
  end

  def description
    parent.description
  end

  def set_name(new_name)
    if new_name.is_a? Array
      self.name = new_name.map(&:to_s).join('|')
    else
      self.name = new_name.to_s
    end
  end

  def display_name
    width = ArrayProgressConfiguration.item_width
    ret = (description + ' ' + self.name + ' ' + self.extra_name)
    ret = ret.gsub("\n", ' ')
    ret = ret.strip
    ret = ret[0..width-1]
    ret = ret.ljust(width, ' ')
    ret
  end

  def reprint!
    print "\r"
    print progress_colored
    print name_colored
    print result_colored
  end

  def progress_colored
    if status == :error
      progress.light_white.on_light_red
    elsif status == :warning
      progress.black.on_light_yellow
    else
      progress.white
    end
  end

  def name_colored
    if status == :error
      display_name.light_white.on_light_red
    elsif status == :warning
      display_name.black.on_light_yellow
    elsif status == :skip
      display_name.white
    else
      display_name
    end
  end

  def result_colored
    if status == nil
      ''
    elsif status == :ok
      ' [ Success ]'.green.bold
    elsif status == :error
      ' [ Failure ]'.light_white.on_light_red
    elsif status == :warning
      ' [ Warning ]'.black.on_light_yellow
    elsif status == :skip
      ' [ Skipped ]'.white.bold
    else
      ' [ Unknown ]'.bold
    end
  end
end
