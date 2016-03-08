module Dapper
  # File Monitor
  module Filelock
    def self.included(base)
      base.extend(ClassMethods)
    end

    # ClassMethods
    module ClassMethods
      def filelocks
        @filelocks ||= Hash.new(false)
      end
    end

    def filelock(filelock, error_message: 'Already in use!', timeout: 10, &blk)
      return yield if self.class.filelocks[filelock]

      begin
        self.class.filelocks[filelock] = true
        filelock_lockfile(filelock, error_message: error_message, timeout: timeout, &blk)
        yield
      ensure
        self.class.filelocks[filelock] = false
      end
    end

    protected

    def filelock_lockfile(filelock, error_message: 'Already in use!', timeout: 10)
      File.open(build_path(filelock), File::RDWR | File::CREAT, 0644) do |file|
        Timeout.timeout(timeout) do
          file.flock(File::LOCK_EX)
        end

        yield
      end
    rescue Timeout::Error
      STDERR.puts error_message
      exit 1
    end
  end
end