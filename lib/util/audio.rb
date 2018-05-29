# frozen_string_literal: true

module Util
  ###
  # Utility class for manipulating audio data
  ###
  class Audio
    class << self
      # Parameters:
      #   audio (array):
      #     A stream of audio data, must be mono
      # Returns:
      #   valid (boolean):
      #     Is valid audio data?
      def validate(audio)
        len = audio.length
        sample = audio[len - 1]

        (len > 2) && (valid_format? sample)
      end

      # Is the data either Float or array that includes floats
      def valid_format?(data)
        if data.is_a? Array
          (valid_format? data[0]) && (valid_format? data[1])
        else
          data.is_a? Float
        end
      end
    end
  end
end
