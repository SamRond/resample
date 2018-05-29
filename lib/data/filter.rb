# frozen_string_literal: true

###
# Filter
###
class Filter
  attr_reader :half_window, :rolloff, :precision
  FILTERS = {
    'kaiser_fast': {
      datafile: '/kaiser_fast.bin',
      rolloff: 0.85,
      precision: 512
    },
    'kaiser_best': {
      datafile: '/kaiser_best.bin',
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
    @datafile = File.dirname(__FILE__) + filter[:datafile]
    @rolloff = filter[:rolloff]
    @precision = filter[:precision]
  end

  def self.dump(path)
    data = ''
    f = File.open(path, 'r')
    f.each_line do |line|
      data += line
    end

    data = data.gsub(/\s+/m, ' ').strip.split(' ')
    data = data.map(&:to_f)
    File.open('./data/kaiser_best.bin', 'wb') { |b| b.write(Marshal.dump(data)) }
  end
end
