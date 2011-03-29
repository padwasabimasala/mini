require 'ostruct'
require 'mini'

module Mini
  @@env ||= (ENV['MINI_ENV'] || 'development').dup

  class << self
    def share
      if %w[production development].include? Mini.env
        File.join(SHARE_ROOT, Mini.env)
      else
        File.join(MINI_ROOT, Mini.env)
      end
    end

    def db_lockfile_path
      File.join(SHARE_ROOT, "db", "backup_lock")    
    end

    def db_last_backup_path
      File.join(SHARE_ROOT, "db", "backup_last")    
    end

    def share_is_nfs?
      File.exist?(SHARE_ROOT + '/.NFS_MOUNT_CHECK')
    end

    def env 
      @@env
    end

    def env=(env)
      @@env = env
    end
      
    def config
      @@config
    end

    def config=(config)
      @@config = config
    end
  
    def initialized?
      defined?(@initialized) ? @initialized : false
    end

    def initialized=(initialized)
      @initialized ||= initialized
    end
  end
    
  class Initializer
    def self.run
      return if Mini.initialized?
      config = OpenStruct.new
      yield(config) if block_given?
      env_file = File.join(MINI_ROOT, "config", "env", "#{Mini.env}.rb")
      eval(IO.read(env_file)) if File.exist? env_file
      override_file = File.join(Mini.share, "config","override.rb")
      eval(IO.read(override_file)) if File.exist?(override_file)
      Mini.config = config
      Mini.initialized = true
    end
  end

end
