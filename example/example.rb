require './lib/array_with_progress.rb'

class Example
  attr_accessor :name, :data, :status

  def self.generate(n)
    (1..n).map do
      example = Example.new

      names = %w{James John Robert Michael William David Richard Charles Joseph Thomas Christopher Daniel Paul Mark Donald George Kenneth Steven Edward Brian}
      surnames = %w{Smith Johnson Williams Brown Jones Miller Davis Garcia Rodriguez Wilson Martinez Anderson Taylor Thomas Hernandez Moore Martin Jackson Thompson White}

      example.name = "#{names.sample} #{surnames.sample}"
      if rand(100) > 20
        id = 'abcdefghijklmnopqrstuvwxyz0123456789'.split(//).sample(16).join
        example.data = "http://example.server/user_details/#{example.name.downcase.gsub(' ', '_')}/#{id}.json"
        example.status = %i{ok ok ok ok ok ok ok ok warning warning error}.sample
      end
      example
    end
  end

  def to_s
    "User '#{name}'"
  end
end

Example.generate(30).each_with_progress('Reindex data for') do |user, operation|
  if user.data
    operation.expand_name('[details available]')
    sleep 0.5
    operation.expand_name("[#{user.data}]")
    sleep 1
    if user.status == :error
      operation.expand_name("[#{user.data} - HTTP 404 Not Found!]")
    elsif user.status == :warning
      operation.expand_name("[#{user.data} - version mismatch]")
    end
    user.status
  else
    :skip
  end
end
