require 'fileutils'

module Mini::Util
  module Debug
    DEBUG_ROOT = File.join(MINI_ROOT, "debug")
    FileUtils.mkdir_p(DEBUG_ROOT) unless File.exists?(DEBUG_ROOT)
    
    def debug_page(page, title, excp=nil)
      puts "HELLO"
      File.open(File.join(DEBUG_ROOT, generate_debug_page_title(title)), "w") do |f|
        content = page.respond_to?(:body) ? page.body : page
        f.write(content) 
        if excp
          f.puts
          f.puts("=" * 80)
          f.puts excp.class
          f.puts excp.message
          f.puts excp.backtrace
        end
      end
    end
    
    def generate_debug_page_title(title)
      "#{title.to_s}-#{Time.now.to_i.to_s}.html"
    end
  end
end
