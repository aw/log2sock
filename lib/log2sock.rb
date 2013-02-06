class Log2sock
  require 'socket'
  require 'date'

  DEFAULT_SOCKET = "/tmp/log2.sock"

  # Log levels
  DEBUG   = 'debug'
  INFO    = 'info'
  WARN    = 'warn'
  ERROR   = 'error'
  FATAL   = 'fatal'
  UNKNOWN = 'unknown'

  # Public: initializer
  #
  # log2sockfile  - The String filename of the UNIX domain socket
  #                 (default: Log2sock::DEFAULT_SOCKET)
  #
  # This method performs the following tasks:
  # * set the default log severity level
  # * obtain the process ID number
  # * set the socket file name
  # * try to open the socket for writing
  # * revert to STDOUT if the socket can't be opened
  #
  # Examples:
  #
  #   logger = Log2sock.new("/tmp/mylogs.sock")
  #
  #   logger = Log2sock.new
  #
  # Returns nothing useful
  #
  def initialize(log2sockfile = DEFAULT_SOCKET)
    @loglevel = DEBUG
    @pid = Process.pid

    begin
      @socketfile = log2sockfile
      @socket = UNIXSocket.open(@socketfile)
    rescue Exception => e
      set_socket_stdout(e)
    end
  end

  # Public: send a message to the socket or STDOUT
  #
  # msg       - The optional String unescaped message you want to log (default: nil)
  # severity  - The String or CONSTANT log level severity of the message
  # &block    - The String reference block which doesn't necessarily get evaluated
  #
  # This method performs the following tasks:
  # * create a timestamp similar to this: 2013-02-07T03:58:09.902243
  # * create a prefix for each log message with the severity, timestamp and process id
  # * verifies if a block exists before setting the output message
  # * tries to output the message to the socket or STDOUT
  #
  # Examples:
  #
  #   logger.message("This is a debug message", Log2sock::DEBUG)
  #
  #   logger.message(Log2sock::INFO) { "This is a debug message" }
  #
  # Returns nothing useful
  #
  def message(msg = nil, severity, &block)
    d = DateTime.now
    timestamp = d.strftime("%Y-%m-%dT%H:%M:%S.%6N")
    # we use rjust(7) because the longest 'severity' is "unknown" which is 7 chars long
    prefix = "#{severity[0].upcase}, [#{timestamp} \##{@pid}] #{severity.upcase.rjust(7)} -- :"

    if block_given?
      message = yield
    else
      message = msg
    end

    begin
      @socket.puts "#{prefix} #{message}"
    rescue Exception => e
      # If the socket generates and exception, set the output
      # to STDOUT for future calls to message()
      set_socket_stdout(e)
      @socket.puts "#{prefix} #{message}"
    end
  end

  # Public: set the log severity level
  #
  # level - The String or CONSTANT log level severity (default: nil)
  #
  # Notes:
  # * if the log level is not sent as a parameter, it simply returns the current log level
  # * if the log level is sent as a parameter, the new log level is set
  #
  # Examples:
  #
  #   puts logger.level
  #
  #   logger.level(Log2sock::INFO)
  #
  # Returns The String of the current log severity level
  #
  def level(level = nil)
    @loglevel = level unless level == nil
    return @loglevel
  end

  # Public: generate a <SEVERITY> log message
  #
  # msg     - The String unescaped message you want to log (default: nil)
  # &block  - The String reference block which doesn't necessarily get evaluated
  #
  # Notes:
  # * calls the message() method only if the log severity level is is equal or higher priority
  # * if a block is given, it will only be evaluated if the conditions are met
  # * same functionality for all 6 log severity levels
  #
  # Examples:
  #
  #   logger.warn("This is a warn message")
  #
  #   logger.info { "This is an info message" }
  #
  #   logger.level(Log2sock::INFO)
  #   logger.debug { "This is an unevaluated debug message #{5/0}" } # <-- only evaluated if severity is DEBUG
  #
  # Returns true if the message() is called, false if it isn't
  #
  def debug(msg = nil, &block)
    if [DEBUG].include? @loglevel
      message(msg, DEBUG, &block)
      return true
    end
    return false
  end

  def info(msg = nil, &block)
    if [DEBUG, INFO].include? @loglevel
      message(msg, INFO, &block)
      return true
    end
    return false
  end

  def warn(msg = nil, &block)
    if [DEBUG, INFO, WARN].include? @loglevel
      message(msg, WARN, &block)
      return true
    end
    return false
  end

  def error(msg = nil, &block)
    if [DEBUG, INFO, WARN, ERROR].include? @loglevel
      message(msg, ERROR, &block)
      return true
    end
    return false
  end

  def fatal(msg = nil, &block)
    if [DEBUG, INFO, WARN, ERROR, FATAL].include? @loglevel
      message(msg, FATAL, &block)
      return true
    end
    return false
  end

  def unknown(msg = nil, &block)
    if [DEBUG, INFO, WARN, ERROR, FATAL, UNKNOWN].include? @loglevel
      message(msg, UNKNOWN, &block)
      return true
    end
    return false
  end

  private

  # Private: set the socket log output to STDOUT
  #
  # error - The String error message explaining why we're logging to STDOUT instead of a UNIX domain socket
  #
  # Notes:
  # * if this is called, we set the output using the global $stdout variable
  # * prints the error message to STDOUT, obviously
  #
  # Example:
  #
  #   set_socket_stdout("Exception error message")
  #
  # Returns nothing useful
  #
  def set_socket_stdout(error)
    @socket = $stdout
    @socket.puts "Error opening socket, logging to STDOUT: #{error}"
  end
end
