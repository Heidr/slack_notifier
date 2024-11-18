# frozen_string_literal: true

module Slack
  class Base
    def client
      @client ||= Slack::Web::Client.new
    end
  end
end
