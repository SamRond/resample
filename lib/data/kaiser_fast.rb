# frozen_string_literal: true

###
# Implementation of kaiser_fast resampling filter
#   16 zero-crossings,
#   Kaiser window with beta=8.555504641634386,
#
###
class KaiserFast
  attr_reader :half_window, :rolloff, :precision
  DATAFILE = './kaiser_fast.bin'

  # initialize class variables
  def initialize
    # the interpolation window (right-hand side)
    @half_window = Marshal.load(File.binread(DATAFILE)).map(&:to_f)

    # the roll-off frequency (as a fraction of nyquist)
    @rolloff = 0.85

    # the number of filter coefficients to retain for each zero-crossing
    @precision = 512
  end
end
