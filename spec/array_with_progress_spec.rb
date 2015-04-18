require 'spec_helper'
begin
  require 'active_record'
rescue LoadError
end

describe ArrayWithProgress do
  before do
    String.disable_colorization = true
    allow(ArrayProgressConfiguration).to receive(:terminal_width).and_return(60)
  end

  it 'has a version number' do
    expect(ArrayWithProgress::VERSION).not_to be nil
  end

  it 'should work on single item string array' do
    expect do
      ['Foo'].each_with_progress do |item|
        :ok
      end
    end.to output(<<END).to_stdout
\r[  0.0%] Foo                                   \r[  0.0%] Foo                                    [ Success ]
END
  end

  it 'should work on multiple item string array' do
    expect do
      ['Foo', 'Bar', 'Zomb'].each_with_progress do |item|
        :ok
      end
    end.to output(<<END).to_stdout
\r[  0.0%] Foo                                   \r[  0.0%] Foo                                    [ Success ]
\r[ 33.3%] Bar                                   \r[ 33.3%] Bar                                    [ Success ]
\r[ 66.7%] Zomb                                  \r[ 66.7%] Zomb                                   [ Success ]
END
  end

  it 'should allow to add description to the work queue' do
    expect do
      ['Foo'].each_with_progress('Processing') do |item|
        :ok
      end
    end.to output(<<END).to_stdout
\r[  0.0%] Processing Foo                        \r[  0.0%] Processing Foo                         [ Success ]
END
  end

  it 'should allow to change item name during the processing' do
    expect do
      ['Foo'].each_with_progress('Processing') do |item, op|
        op.change_name('New name')
        :ok
      end
    end.to output(<<END).to_stdout
\r[  0.0%] Processing Foo                        \r[  0.0%] Processing New name                   \r[  0.0%] Processing New name                    [ Success ]
END
  end

  it 'should allow to add extra information to item name during the processing' do
    expect do
      ['Foo'].each_with_progress('Processing') do |item, op|
        op.expand_name('test')
        :ok
      end
    end.to output(<<END).to_stdout
\r[  0.0%] Processing Foo                        \r[  0.0%] Processing Foo test                   \r[  0.0%] Processing Foo test                    [ Success ]
END
  end

  it 'should accept different symbols as status codes' do
    expect do
      %w{ok skip warning error not_defined}.each_with_progress do |item|
        item.to_sym
      end
    end.to output(<<END).to_stdout
\r[  0.0%] ok                                    \r[  0.0%] ok                                     [ Success ]
\r[ 20.0%] skip                                  \r[ 20.0%] skip                                   [ Skipped ]
\r[ 40.0%] warning                               \r[ 40.0%] warning                                [ Warning ]
\r[ 60.0%] error                                 \r[ 60.0%] error                                  [ Failure ]
\r[ 80.0%] not_defined                           \r[ 80.0%] not_defined                            [ Unknown ]
END
  end

  it 'should expand array items' do
    expect do
      [['foo', 'bar', 'zomb']].each_with_progress do |item|
        :ok
      end
    end.to output(<<END).to_stdout
\r[  0.0%] foo|bar|zomb                          \r[  0.0%] foo|bar|zomb                           [ Success ]
END
  end

  it 'should accept true as ok status code' do
    expect do
      ['Foo'].each_with_progress do |item|
        true
      end
    end.to output(<<END).to_stdout
\r[  0.0%] Foo                                   \r[  0.0%] Foo                                    [ Success ]
END
  end

  it 'should accept false as error status code' do
    expect do
      ['Foo'].each_with_progress do |item|
        false
      end
    end.to output(<<END).to_stdout
\r[  0.0%] Foo                                   \r[  0.0%] Foo                                    [ Failure ]
END
  end

  it 'should show unknown status for undefined status codes' do
    expect do
      ['Foo'].each_with_progress do |item|
        nil
      end
    end.to output(<<END).to_stdout
\r[  0.0%] Foo                                   \r[  0.0%] Foo                                    [ Unknown ]
END
  end

  if defined?(ActiveRecord)
    it 'should process items in member transaction if specified' do
      expect(ActiveRecord::Base).to receive(:transaction).exactly(3).times do |_, &block|
        block.call
      end
      array = ['Foo', 'Bar', 'Zomb']
      array.each do |item| expect(item).to receive(:ping).and_return(:ok) end
      expect do
        array.each_with_progress('', transaction: :member) do |item|
          item.ping
        end
      end.to output.to_stdout
    end

    it 'should process items in collection transaction if specified' do
      expect(ActiveRecord::Base).to receive(:transaction).exactly(1).times do |_, &block|
        block.call
      end
      array = ['Foo', 'Bar', 'Zomb']
      array.each do |item| expect(item).to receive(:ping).and_return(:ok) end
      expect do
        array.each_with_progress('', transaction: :collection) do |item|
          item.ping
        end
      end.to output.to_stdout
    end
  end
end
