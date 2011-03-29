module Mini::Util
  module CLI
    def fail(message = "Fail!")
      STDERR.write(message + "\n")
      exit 1
    end

    def continue?(question=nil, default_response=false)
      question ||= "Are you sure you wish to continue?"
      question += default_response ? " (Y/n)" : " (y/N)"
      puts question
      case STDIN.gets.downcase.strip
        when 'y' then true
        when 'n' then false
        when '' then default_response
        else false
      end
    end

    def tell(message)
      Mini.log.info message
      puts message
    end

    # Make instance methods available as class methods. Mwoo hah hah hah ;)
    def self.method_missing(method, *args, &block)
      if instance_methods.include? method.to_s
        obj = self.class.new
        obj.extend self
        obj.send(method, *args)
      end
    end
  end
end

