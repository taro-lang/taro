module ::Taro::Compiler
  class Analyzer
    property source : IO
    property buffer : IO::Memory
    property pos : Int32
    property current_char : Char

    def initialize(@source : IO)
      @buffer = IO::Memory.new
      @pos = 0
      @current_char = read_char
    end

    def read_char(save_in_buffer = true) : Char
      char = @source.read_char
      char = '\0' unless char.is_a?(Char)

      @current_char = char
      @pos += 1
      @buffer << char if save_in_buffer

      char
    end

    def peek_char : Char
      if (slice = @source.peek) && !slice.empty?
        slice[0].chr
      else
        '\0'
      end
    end

    # Remove the last-read character from the buffer, effectively skipping it.
    def skip_last_char
      # TODO: Fix this to work for multi-byte characters
      @buffer.seek(-1, IO::Seek::Current)
    end

    def finished? : Bool
      if slice = @source.peek
        slice.empty?
      else
        true
      end
    end

    def buffer_value
      buffer.to_s[0..-2]
    end
  end
end
