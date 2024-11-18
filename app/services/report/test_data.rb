# frozen_string_literal: true

module Report
  class TestData
    def call(data_count:)
      test_data = sorted_test_data(data_count)
      divided_data = divided_data(test_data)
      save_to_csv(divided_data) if data_count > 5
      latest_five_string(test_data)
    end

    def sorted_test_data(data_count)
      now = Time.now
      two_weeks_ago = now - 2.weeks

      data = (0...data_count).map do
        timestamp = rand(two_weeks_ago.to_i..now.to_i)
        {
          email: "user#{SecureRandom.hex(3)}@example.com",
          scheduled_at: Time.at(timestamp)
        }
      end

      data.sort_by { |entry| entry[:scheduled_at] }.reverse
    end

    def divided_data(data)
      cutoff_index = data.index { |entry| entry[:scheduled_at] <= Time.now - 7.days }

      this_week = data[0..(cutoff_index-1)]
      previous_week = data[cutoff_index..-1]

      { this_week: this_week, previous_week: previous_week }
    end

    def save_to_csv(divided_data)
      CSV.open(Rails.root.join("tmp", "data.csv"), "wb") do |csv|
        csv << [ "email", "scheduled_at" ]

        csv << []
        csv << [ "This Week" ]

        divided_data[:this_week].each do |item|
          csv << [ item[:email], item[:scheduled_at] ]
        end

        csv << []
        csv << [ "Previous Week" ]
        divided_data[:previous_week].each do |item|
          csv << [ item[:email], item[:scheduled_at] ]
        end
      end
    end

    def latest_five_string(data)
      data.first(5).map do |record|
        "#{record[:email]} | scheduled at: #{record[:scheduled_at]}\n"
      end.join
    end
  end
end
