# Try loading Rubygems
begin ; require 'rubygems' ; rescue LoadError ; end

# Don't start out quiet
$quiet = false

# Convenience function for handling exceptions
def handle_exception(exception, text)
  unless $quiet or exception.class == SystemExit
    $stderr.puts "ERROR: Exception occured while #{text}:\n"
    $stderr.puts exception
    $stderr.puts exception.backtrace.join("\n")
  end
  exit(1)
end

# Convenience function for printing errors
def error(s, pre='ERROR')
  $stderr.puts pre + ': ' + s unless $quiet
  exit(1)
end

# Convenience function for requiring libraries
def nanoc_require(x)
  require x
rescue LoadError
  error("This site requires #{x} to be built.")
end

require 'fileutils'

class FileLogger

  COLORS = {
    :reset   => "\e[0m",

    :bold    => "\e[1m",

    :black   => "\e[30m",
    :red     => "\e[31m",
    :green   => "\e[32m",
    :yellow  => "\e[33m",
    :blue    => "\e[34m",
    :magenta => "\e[35m",
    :cyan    => "\e[36m",
    :white   => "\e[37m"
  }

  ACTION_COLORS = {
    :create     => COLORS[:bold] + COLORS[:green],
    :update     => COLORS[:bold] + COLORS[:yellow],
    :move       => COLORS[:bold] + COLORS[:blue],
    :identical  => COLORS[:bold]
  }

  def log(action, path)
    puts('%s%12s%s  %s' % [ACTION_COLORS[action.to_sym], action, COLORS[:reset], path]) unless $quiet
  end

private

  def method_missing(method, *args)
    log(method.to_s, args.first)
  end

end

class FileManager

  @@stack = []
  @@logger = FileLogger.new

  def self.create_dir(name)
    @@stack.pushing(name) do
      path = File.join(@@stack)
      unless File.directory?(path)
        FileUtils.mkdir_p(path)
        @@logger.create(path)
      end
      yield if block_given?
    end
  end

  def self.create_file(name)
    path = File.join(@@stack + [ name ])
    FileManager.create_dir(path.sub(/\/[^\/]+$/, '')) if @@stack.empty?
    content = block_given? ? yield : nil
    if File.exist?(path)
      if block_given? and File.read(path) == content
        @@logger.identical(path)
      else
        @@logger.update(path)
      end
    else
      @@logger.create(path)
    end
    open(path, 'w') { |io| io.write(content) unless content.nil? }
  end

end
