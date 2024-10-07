# frozen_string_literal: true

require_relative './dog'

dog = Dog.new(
  name: 'rufus',
  age: 2
)

puts dog.inspect
