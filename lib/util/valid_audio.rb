# frozen_string_literal: true

require 'bigdecimal'

module Util
  ###
  # Utility class for verifying the validity of audio data
  ###
  class ValidAudio
    # Parameters:
    #   audio (array):
    #     A stream of audio data, must be mono
    # Returns:
    #   valid (boolean):
    #     Is valid audio data?
    def self.validate(audio)
      len = audio.length
      sample = audio[len - 1]

      (len > 2) && (valid_format? sample)
    end

    private

    # Is the data either Float, BigDecimal, or array that includes those
    def valid_format?(data)
      if data.is_a? Array
        (valid_format? data[0]) && (valid_format? data[1])
      else
        (data.is_a? Float) || (data.is_a? BigDecimal)
      end
    end
  end
end
