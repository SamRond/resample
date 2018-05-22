# frozen_string_literal: true

# Yes, I know... but a monkey patch is quick and easy
class Array
  # Rough approximation of numpy 'shape'
  def shape
    shape = [length]
    shape.push(self[0].shape) if all? { |x| x.is_a? Array }

    shape.flatten
  end
end
