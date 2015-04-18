require 'array_with_progress/version'
require 'array_with_progress/array_progress_operation'

class Array
  def each_with_progress(description = '', options = {}, &block)
    ArrayProgressOperation.new(self, description, options).run!(&block)
  end
end

module ArrayWithProgress
end
