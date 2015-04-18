# ArrayWithProgress

[![Build Status](https://travis-ci.org/dabroz/array_with_progress.svg?branch=master)](https://travis-ci.org/dabroz/array_with_progress) [![Coverage Status](https://coveralls.io/repos/dabroz/array_with_progress/badge.svg)](https://coveralls.io/r/dabroz/array_with_progress) [![Gem Version](https://badge.fury.io/rb/array_with_progress.svg)](http://badge.fury.io/rb/array_with_progress)

Easily visualize progress of any Ruby task. A drop in replacement for `Array.each`.

Output uses different colors for successes/failured, allowing to easily check status of every task. Every line is trimmed/padded to match the terminal width. There is also a possiblity to change item name during processing. Transactions for `ActiveRecord` are also handled if required.

![array_with_progress](https://cloud.githubusercontent.com/assets/179706/7215359/5cb6d116-e5d4-11e4-9a77-165e75330cfe.png)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'array_with_progress'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install array_with_progress

## Usage

Basic usage is as easy as replacing all `Array.each` to `Array.each_with_progress` in your rake tasks.

```ruby
User.all.each_with_progress do |user|
  user.backup_avatar!
end
```

One of the main features is the ability to provide statuses for each task. To do that, just return one of the following in your block:

- `:ok` (or `true`) - Success
- `:warning` - Success, but with some warnings
- `:error` (or `false`) - Failure
- `:skip` - Task was skipped

```ruby
User.all.each_with_progress do |user|
  if user.has_avatar?
    user.backup_avatar! # returns true/false
  else
    :skip
  end   
end
```

You can provide a description for task block (useful if many different operations are to be performed on the same collection):

```ruby
User.all.each_with_progress('Backing up the avatar for') do |user|
  user.backup_avatar!
end
```

To change item name during processing (for example when performing migration on some data, and the correct name is discovered after some processing) use an extra block argument and one of the following:

```ruby
User.all.each_with_progress('Backing up the avatar for') do |user, operation|
  operation.change_name(user.avatar_path) # this will completely replace username in output
  operation.expand_name(user.avatar_path) # this will append extra data to the username
  user.backup_avatar!
end
```

For `ActiveRecord` objects, to enclose processing in transaction you can use additional option `transaction`. It can be one the following:

- `none` - no transaction (default)
- `collection` - wrap whole array in a single transaction
- `member` - wrap every item in a separate transaction

```ruby
User.all.each_with_progress('Backing up the avatar for', transaction: :collection) do |user|
  user.backup_avatar!
end
```

More complicated example:

```ruby
User.all.each_with_progress('Reindex data for', transaction: :collection) do |user, operation|
  if user.details_available?
    operation.expand_name("[#{user.details_url}]")
    begin
      if user.reindex_details!
        :ok
      else
        operation.expand_name("[#{user.details_url} - version mismatch]")
        :warning
      end
    rescue UserDetailsHTTPError => e
      operation.expand_name("[#{user.details_url} - HTTP 404 Not Found!]")
      :error
    end
  else
    :skip
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment. 

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/dabroz/array_with_progress/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
