# frozen_string_literal: true

###
# Filter
###
class Filter
  attr_reader :half_window, :rolloff, :precision
  FILTERS = {
    'kaiser_fast': {
      datafile: '/data/kaiser_fast.bin',
      rolloff: 0.85,
      precision: 512
    },
    'kaiser_best': {
      datafile: '/data/kaiser_best.bin',
      rolloff: 0.9475937167399596,
      precision: 512
    }
  }.freeze

  def initialize(filter_name)
    load_filter(filter_name)
    @half_window = Marshal.load(File.binread(@datafile)).map(&:to_f)
  end

  def load_filter(name)
    filter = FILTERS[name.to_sym]
    @datafile = filter[:datafile]
    @rolloff = filter[:rolloff]
    @precision = filter[:precision]
  end
end
