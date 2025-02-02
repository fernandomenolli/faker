# frozen_string_literal: true

require_relative '../../test_helper'

class TestFakerZipCode < Test::Unit::TestCase
  def setup
    @zip_codes_without_state = %w[50817 48666 55551 14242 99852]
    @zip_codes_with_state = %w[55555 44444 33333 22222 11111]

    @old_locales = I18n.config.available_locales

    locale_without_state = {
      faker: {
        address: {
          state_abbreviation: [''],
          postcode: @zip_codes_without_state
        }
      }
    }

    locale_with_state = {
      faker: {
        address: {
          postcode_by_state: {
            NY: @zip_codes_with_state
          }
        }
      }
    }

    I18n.config.available_locales += %i[xy xz]
    I18n.backend.store_translations(:xy, locale_without_state)
    I18n.backend.store_translations(:xz, locale_with_state)
    @tester = Faker::Address
  end

  def teardown
    I18n.config.available_locales = @old_locales
  end

  def test_zip_code_can_have_leading_zero
    zip_codes = []
    1000.times { zip_codes << @tester.zip_code }

    assert zip_codes.any? { |zip_code| zip_code[0].to_i.zero? }
  end

  def test_default_zip_codes_without_states
    I18n.with_locale(:xy) do
      zip_codes = @zip_codes_without_state
      100.times do
        zip_code = @tester.zip_code

        assert_includes zip_codes, zip_code, "Expected <#{zip_codes.join(' / ')}>, but got #{zip_code}"
      end
    end
  end

  def test_zip_codes_with_states
    I18n.with_locale(:xz) do
      zip_codes = @zip_codes_with_state
      100.times do
        zip_code = @tester.zip_code(state_abbreviation: 'NY')

        assert_includes zip_codes, zip_code, "Expected <#{zip_codes.join(' / ')}>, but got #{zip_code}"
      end
    end
  end
end
