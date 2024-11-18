# frozen_string_literal: true

require "net/http"
require "json"
require "uri"
require "csv"

module Slack
  class PostMessage < Base
    def post_message(channel:, blocks:, file_path:)
      @file_path = file_path
      @channel = channel

      files_uploader.prepare_upload

      client.chat_postMessage(
        channel: @channel,
        text: "fallback message #{files_uploader.upload_details.file_id}",
        blocks: blocks,
        attachments: [ {
          fallback: "a csv file was supposed to be here",
          file: files_uploader.upload_details.file_id,
          filename: "thecsv.csv"
        } ].to_json
      )

      files_uploader.complete_files_upload
    end

    private

    def files_uploader
      @files_uploader ||= Slack::FilesUpload.new(channel: @channel, file_path: @file_path)
    end
  end
end
