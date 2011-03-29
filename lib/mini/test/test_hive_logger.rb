require File.dirname(__FILE__) + '/setup'
require 'stringio'
require 'tempfile'
require 'mini'
require 'mini/logger'

class DualLoggerTest < Test::Unit::TestCase
  def setup
    @dual_logger = Mini::Logger::DualLogger.new(:err)
  end

  def teardown
  end

  def default_log
    @dual_logger.instance_variable_get(:@logs)[:default]
  end

  def extra_log
    @dual_logger.instance_variable_get(:@logs)[:extra]
  end

  def extra_log_log
    extra_log.instance_variable_get("@log")
  end

  def test_initialize
    assert_equal(Mini::Logger::DEFAULT_LOG_LEVEL, default_log.level)
    assert_equal(true, extra_log == nil)
  end

  def test_extra_log=
    assert_equal(nil, @dual_logger.instance_variable_get(:@extra_log))
    @dual_logger.extra_log = StringIO.new
    assert_equal(true, extra_log != nil)
    assert_equal(default_log.level, extra_log.level)
  end

  def test_level=
    # Test that the level changes
    @dual_logger.level = :debug
    debug_level = default_log.level
    @dual_logger.level = :info
    info_level = default_log.level
    assert_equal(true, debug_level != info_level)

    # Test that default_log and extra_log levels are the same
    @dual_logger.extra_log = StringIO.new
    assert_equal(default_log.level, extra_log.level)
    @dual_logger.level = :err
   assert_equal(default_log.level, extra_log.level)
  end

  def test_log_method
    extra_log_file = StringIO.new
    @dual_logger.process_name= :foo
    @dual_logger.level = :err
    @dual_logger.extra_log = extra_log_file
    warn = "My warning msg"
    @dual_logger.warning warn
    extra_log_log.seek 0
    assert_equal(true, extra_log_log.readlines == [])
    extra_log_file.seek 0
    assert_equal(true, extra_log_file.readlines == [])

    err = "My error msg"
    @dual_logger.err err
    extra_log_log.seek 0
    assert_equal(true, (extra_log_log.readlines[0] =~ /foo/) != nil)
    extra_log_log.seek 0
    assert_equal(true, (extra_log_log.readlines[0] =~ /#{err}/) != nil)
    extra_log_file.seek 0
    assert_equal(true, (extra_log_file.readlines[0] =~ /#{err}/) != nil)
  end

  def test_excp
    begin
      raise StandardError.new "This is a test exception."
    rescue => e
      @dual_logger.excp e
    end
  end

end

class LoggerTest < Test::Unit::TestCase
  def test_logger
    ENV['LOG_LEVEL'] = nil
    extra_io = StringIO.new
    Mini.log.level = :warning
    Mini::Logger.extra_log = extra_io
    Mini.log.info "You shouldn't see this"
    Mini.log.warning "You should see this"
    extra_io.seek 0
    assert_equal(1, extra_io.readlines.length)
    ENV['LOG_LEVEL'] = 'debug'
    Mini.log.info "You should see this now"
    extra_io.seek 0
    assert_equal(2, extra_io.readlines.length)
  end
end
