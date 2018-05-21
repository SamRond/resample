require 'resample/version'


module Resample
  module_function

  ###
  # Resamples input audio
  # Parameters:
  #   in:
  #     Input audio stream, in the form of an array of floats
  #
  #   original_sr:
  #     Original sample rate
  #
  #   new_sr:
  #     New sample rate
  #
  #   filter:
  #     Resampling filter to use, either "kaiser_best" or "kaiser_fast"
  #
  # Returns:
  #   Resampled array of floats
  ###
  def resample(in, original_sr, new_sr, filter='kaiser_best')
    if sr_orig <= 0
      raise ArgumentError.new("Invalid sample rate: sr_orig={#{sr_orig}}")
    end

    if sr_new <= 0
      raise ArgumentError.new("Invalid sample rate: sr_new={#{sr_new}}")
    end
  end
end
