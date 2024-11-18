# frozen_string_literal: true

module Report
  class SendReport
    def initialize(data_count:)
      @data_count = data_count
      @channel = ENV["SLACK_NOTIFS_CHANNEL"]
      @file_path = "tmp/data.csv"
    end

    def post_to_slack
      Slack::PostMessage.new.post_message(channel: @channel, blocks: blocks, file_path: @file_path)
    end

    def blocks
      latest_records = Report::TestData.new.call(data_count: @data_count)
      [
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "*Latest records:*:\n #{latest_records}"
          }
        }
      ].to_json
    end
  end
end
