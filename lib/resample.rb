# frozen_string_literal: true

require 'resample/version'
require 'data/filter'
require 'util/audio'
require 'util/fix_length'
require 'core_extensions/array'

require 'byebug'
###
# Resample array of audio data
###
module Resample
  module_function

  ###
  # Resamples input audio
  # Parameters:
  #   in (array):
  #     Input audio stream, in the form of an array of floats
  #
  #   original_sr (integer):
  #     Original sample rate
  #
  #   new_sr (integer):
  #     New sample rate
  #
  #   filter (string):
  #     Resampling filter to use, either "kaiser_best" or "kaiser_fast"
  #
  #   mono (boolean):
  #     Is the input audio stream monophonic?
  #   fix (boolean):
  #     Adjust the length of the resampled signal to be of size exactly
  #     (new_sr * in.length / original_sr).ceil
  #
  # Returns:
  #   Resampled array of floats
  ###
  def resample(
    audio_in,
    original_sr,
    new_sr,
    filter = 'kaiser_best'
  )
    raise ArgumentError, 'Invalid audio' unless Util::Audio.validate(audio_in)

    audio = format_audio(audio_in)
    ratio = new_sr / original_sr.to_f

    filter = Filter.new(filter)

    window = get_window(filter, ratio)
    delta = get_delta(window)

    length = (audio.length * ratio).to_i
    out = Array.new(length) { Array.new(1, 0.0) }

    resample_f(audio, out, ratio, window, delta, filter.precision)

    # calculate proportional number of samples for fix
    Util::FixLength.fix(out, length) if fix
  end

  def resample_f(x, y, sample_ratio, interp_win, interp_delta, num_table)
    scale = [1.0, sample_ratio].min
    time_increment = 1.0 / sample_ratio
    index_step = (scale * num_table).to_i
    time_register = 0.0

    n = 0
    frac = 0.0
    index_frac = 0.0
    offset = 0
    eta = 0.0
    weight = 0.0

    nwin = interp_win.length
    n_orig = x.length
    n_out = y.length
    n_channels = 1

    (0...n_out).each do |t|
      # Grab the top bits as an index to the input buffer
      n = time_register.to_i

      # Grab the fractional component of the time index
      frac = scale * (time_register - n)

      # Offset into the filter
      index_frac = frac * num_table
      offset = index_frac.to_i

      # Interpolation factor
      eta = index_frac - offset

      # Compute the left wing of the filter response
      i_max = [n + 1, ((nwin - offset) / index_step).to_i].min
      (0...i_max).each do |i|
        weight = (interp_win[offset + i * index_step] + eta * interp_delta[offset + i * index_step])
        (0...n_channels).each do |j|
          y[t][j] += weight * x[n - i][j]
        end
      end

      # Invert P
      frac = scale - frac

      # Offset into the filter
      index_frac = frac * num_table
      offset = index_frac.to_i

      # Interpolation factor
      eta = index_frac - offset

      # Compute the right wing of the filter response
      range = [n_orig - i_max - 1 - n + 1, ((nwin - offset) / index_step).to_i].min
      (0...range).each do |k|
        weight = (interp_win[offset + k * index_step] + eta * interp_delta[offset + k * index_step])
        (0...n_channels).each do |j|
          y[t][j] += weight * x[n + k + 1][j]
        end
      end

      # Increment the time register
      time_register += time_increment
    end

    y
  end

  ###
  # Converts stereo samples to mono by doing a simple average
  # Parameters:
  #   audio_in (array):
  #     Array of two-element arrays of samples
  # Returns:
  #   One-dimensional array of float values
  ###
  def to_mono(audio_in)
    if (audio_in[0].is_a? Array) && (audio_in[0].length == 2)
      audio_in.map { |e| (e[0] + e[1]) / 2.0 }
    else
      audio_in
    end
  end

  ###
  # Detects if there is one channel of audio
  # Parameters:
  #   audio_in (array):
  #     Array of samples
  # Returns:
  #   True if the audio is monophonics
  ###
  def detect_mono(audio_in)
    audio_in[0].is_a? Float
  end

  ###
  # Retrieves and formats window to ratio
  # Parameters:
  #   filter (Filter):
  #     Filter object to retrieve half_window from
  #   ratio (float):
  #     ratio of new sample_rate to old
  # Returns:
  #   window (array):
  #     formatted window for resampling
  ###
  def get_window(filter, ratio)
    window = filter.half_window
    window.map { |e| e * ratio } if ratio < 1
  end

  ###
  # Formats audio to monophonic if stereo detected, shapes data
  # Parameters:
  #   audio (array):
  #     input array of audio
  # Returns:
  #   audio (array):
  #     formatted audio data
  ###
  def format_audio(audio)
    data = audio
    data = to_mono(audio) unless detect_mono(audio)

    data.map { |e| [e] }
  end

  ###
  # Retrieves full window delta
  # Parameters:
  #   window (array):
  #     formatted half-window
  # Returns:
  #   delta (array):
  #     full window diff
  ###
  def get_delta(window)
    delta = window.each_cons(2).map { |a, b| b - a }
    delta.push(0.0)

    delta
  end
end
