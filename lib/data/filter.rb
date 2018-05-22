# frozen_string_literal: true

require 'kaiser_best'
require 'kaiser_fast'

###
# Abstract filter class
###
class Filter
  def self.load(filter_name)
    if filter_name == 'kaiser_fast'
      KaiserFast.new
    else
      KaiserBest.new
    end
  end
end
