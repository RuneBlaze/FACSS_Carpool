require 'date'

# The Time for the Deadline is Written here
DEADLINE_END = DateTime.new(2017, 9, 16)
DEADLINE_RANGE = Rational 2 # 2 days

DEADLINE = DEADLINE_END - DEADLINE_RANGE
