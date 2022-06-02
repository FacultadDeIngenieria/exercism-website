require 'test_helper'

class Track::GenerateHelpTest < ActiveSupport::TestCase
  test "generate" do
    track = create :track

    contents = Track::GenerateHelp.(track)
    expected = <<~EXPECTED.strip
      # Help

      Stuck? Try the Ruby gitter channel.

      Should those resources not suffice, check the following pages:

      - The [Ruby track's documentation](https://exercism.org/docs/tracks/ruby)
      - [Exercism's support channel on gitter](https://gitter.im/exercism/support)
      - The [Frequently Asked Questions](https://exercism.org/docs/using/faqs)
    EXPECTED
    assert_equal expected, contents
  end
end
