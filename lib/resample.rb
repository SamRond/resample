# frozen_string_literal: true

require 'resample/version'
require 'data/filter'
require 'util/valid_audio'
require 'util/fix_length'
require 'bigdecimal'

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
    filter = 'kaiser_best',
    fix = true
  )
    raise ArgumentError, "Invalid: sr_orig - #{original_sr}" if sr_orig <= 0
    raise ArgumentError, "Invalid: sr_new - #{new_sr}" if sr_new <= 0
    raise ArgumentError, 'Invalid audio' unless Util::ValidAudio.validate(audio)

    audio = audio_in
    audio = to_mono(audio_in) unless detect_mono(audio_in)

    ratio = new_sr / original_sr.to_f

    filter = Filter.load(filter)

    window = filter.half_window
    window = window.map { |e| e * ratio } if ratio < 1

    interp_delta = window.each_cons(2).map { |a, b| b - a }
    interp_delta.push(BigDecimal(0))

    audio_2d = audio.map { |e| [e] }
    out = Array.new(audio_2d.length, [0])
    audio = resample_f(audio_2d, out, ratio, window, interp_delta, filter.precision)

    # calculate proportional number of samples for fix
    n_samples = (audio_in.length * ratio).ceil
    Util::FixLength.fix(audio, n_samples) if fix

    # TODO: refactor to several methods
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
    n_orig = x.lenth
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
      i_max = min(n + 1, ((nwin - offset) / index_step).to_i)
      (0...i_max).each do |i|
        weight = (interp_win[offset + i * index_step] + eta * interp_delta[offset + i * index_step])
        (0...n_channels).each do |j|
          y[t, j] += weight * x[n - i, j]
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
      (0...[n_orig - i_max - 1 - n + 1, ((nwin - offset) / index_step).to_i].min).each do |k|
        weight = (interp_win[offset + k * index_step] + eta * interp_delta[offset + k * index_step])
        (0...n_channels).each do |j|
          y[t, j] += weight * x[n + k + 1, j]
        end
      end

      # Increment the time register
      time_register += time_increment
    end
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
    (audio_in[0].is_a? Float) || (audio_in[0].is_a? BigDecimal)
  end
end
