module Heathen

  class Executioner
    attr_reader :logger, :last_exit_status

    def initialize(log)
      @logger = log
    end

    # Executes the given argument vector with fork/exec.
    # Returns the command standard output as a String.
    #
    # ----------------------------------------------------------
    # You'd say, "why don't you just use system()"?
    #
    # Because every security conscious coder knows that escaping
    # shell specials is a fragile and error prone practice, that
    # it can be worked around, and most importantly it is a very
    # complex code flow that happens behind the scenes and it is
    # really not worth the saving of writing a simple fork/exec.
    #
    # Also using a pipe pair allows to print the commands output
    # inside a log file for easier debugging when something will
    # go (badly) wrong (tm).
    #
    #   - vjt  Sun Feb 21 20:30:09 CET 2010
    #
    def execute(*argv)

      stdout, stdout_w = IO.pipe
      stderr, stderr_w = IO.pipe

      started = Time.now.to_f
      command = argv.shift

      options = argv.pop if argv.last.class == Hash

      pid = fork {
        stdout.close; STDOUT.reopen(stdout_w)
        stderr.close; STDERR.reopen(stderr_w)

        if options && options[:dir]
          logger.info "chdir '#{options[:dir]}'"
          Dir.chdir(options[:dir])
        end

        # exec [command, argv[0] ] -- For prettier ps(1) listings :-)
        Kernel::exec [ command, "heathen: #{command}" ], *(argv.map(&:to_s))
      }
      logger.info "[#{pid}] spawn '#{command} #{argv.join(' ')}'"

      stdout_w.close; stderr_w.close
      pid, status = Process.wait2
      elapsed = Time.now.to_f - started

      out, err = stdout.read.chomp, stderr.read.chomp
      stdout.close; stderr.close

      if status.exitstatus != 0
        logger.error "[#{pid}] exited with status #{status.exitstatus.inspect}"
      end
      logger.info("[#{pid}] completed in %02.4f" % elapsed)

      logger.info "  stdout: '#{out}'\n" unless out.blank?
      logger.info "  stderr: '#{err}'\n" unless err.blank?

      return (@last_exit_status = status.exitstatus)
    end

    def quartering(heretics)
      @heretics = heretics
      parallel  = (@heretics.size > 4 ? 4 : @heretics.size)

      parallel.times.collect do
        guilty = @heretics.shift
        Thread.fork { slaughter guilty }
      end.map(&:join)
    end

    protected
      def slaughter guilty
        execute(*guilty)
        slaughter(@heretics.shift) unless @heretics.size.zero?
      end
  end
end
