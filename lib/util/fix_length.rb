# frozen_string_literal: true

module Util
  # Utility for fixing the length of an audio stream
  class FixLength
    ###
    # Resize audio stream
    # Parameters:
    #   audio (array):
    #     Array of audio data
    #   size (integer):
    #     Target size of the audio data
    # Returns:
    #   Resized audio data
    ###
    def self.fix(audio, size)
      n = audio.length
      data = audio

      if n > size
        data = data[a...size]
      elsif n < size
        padding = Array.new(size - n, data[-1])
        data = data.concat(padding)
      end

      data
    end
  end
end
