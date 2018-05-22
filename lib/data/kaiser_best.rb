# frozen_string_literal: true

require 'bigdecimal'

###
# Implementation of kaiser_best resampling filter
#   64 zero-crossings,
#   Kaiser window with beta=14.769656459379492
###
class KaiserBest
  attr_reader :half_window, :rolloff, :precision
  DATAFILE = './kaiser_best.bin'

  # initialize class variables
  def initialize
    # the interpolation window (right-hand side)
    @half_window = Marshal.load(File.binread(DATAFILE)).map { |e| BigDecimal(e) }

    # the roll-off frequency (as a fraction of nyquist)
    @rolloff = 0.9475937167399596

    # the number of filter coefficients to retain for each zero-crossing
    @precision = 512
  end

  def self.dump
    arr = []

    File.open(DATAFILE, 'wb') { |f| f.write(Marshal.dump(arr)) }
  end
end
