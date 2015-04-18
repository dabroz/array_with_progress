require 'array_with_progress/array_progress_item'

class ArrayProgressOperation
  attr_accessor :items
  attr_accessor :description
  attr_accessor :transaction

  def initialize(items_, description_, options_)
    self.items = items_
    self.description = description_
    self.transaction = options_[:transaction] || :none
  end

  def run!(&block)
    count = self.items.count.to_f
    run_with_transaction(:collection) do
      self.items.each_with_index do |item, index|
        run_with_transaction(:member) do
          progress = index.to_f / count * 100.0
          ArrayProgressItem.run!(self, item, progress, &block)
        end
      end
    end
  end

  private

  def run_with_transaction(transaction_type)
    if self.transaction == transaction_type
      ActiveRecord::Base.transaction do
        yield
      end
    else
      yield
    end
  end
end
