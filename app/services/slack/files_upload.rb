# frozen_string_literal: true

module Slack
  class FilesUpload < Base
    # https://api.slack.com/messaging/files#uploading_files
    def initialize(channel:, file_path:)
      @channel = channel
      @file_path = file_path
    end

    def upload_details
      @upload_details ||= client.files_getUploadURLExternal(
        filename: File.basename(@file_path),
        length: File.size(@file_path)
      )
    end

    def prepare_upload
      uri = URI.parse(upload_details.upload_url)

      File.open(@file_path, "rb") do |file|
        request = Net::HTTP::Post.new(uri)
        request.body = file.read

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.request(request)
      end
    end

    def complete_files_upload
      client.files_completeUploadExternal(
        files: [
          {
            id: upload_details.file_id,
            title: File.basename(@file_path)
          }
        ].to_json,
        channel_id: @channel,
      )
    end
  end
end
