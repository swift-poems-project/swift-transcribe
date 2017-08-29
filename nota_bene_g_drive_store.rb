
require File.join(File.dirname(__FILE__), 'g_drive_service')

module SwiftPoemsProject
  class NotaBeneGDriveStore

    def initialize(client_secrets_path, scope, app_name, excluded_files = [], cache_path: nil)
      @service = GDriveService.new(client_secrets_path, scope, app_name)
      @excluded_files = excluded_files

      if cache_path.nil?
        @cache_path = File.join(File.dirname(__FILE__), 'tmp', 'nb')
      else
        @cache_path = cache_path
      end
    end

    def get(file)
      results = {}

      gdrive_mtime = file.modified_time
      cached_file_path = File.join(@cache_path, file.name)

      results[:id] = file.name
      results[:mtime] = gdrive_mtime
      
      if File.exists? cached_file_path
        cached_mtime = File.mtime(cached_file_path)
        # Convert this into a DateTime Object
        cached_mtime = DateTime.parse(cached_mtime.to_s)

        if File.exist? cached_file_path
          if gdrive_mtime <= cached_mtime

            results[:mtime] = cached_mtime
            results[:content] = File.read(cached_file_path)
          else
            results[:content] = @service.file(file.id, file.name)
          end

        else
          results[:content] = @service.file(file.id, file.name)
        end
      else
        results[:content] = @service.file(file.id, file.name)
      end

      return results
    end
    
    def transcript(transcript_id)
      unless @excluded_files.include? transcript_id
        files = @service.files("name = '#{transcript_id}'")
        get(files.last)
      end
    end

    def poems()
      files = @service.files()

      files.reject { |file| @excluded_files.include? file.name }.map do |file|
        get(file)
      end
    end

    def get_cached_transcripts(poem_id: nil)
      cached_file_paths = Dir.glob(File.join(@cache_path, "#{poem_id}*"))
      return cached_file_paths.map { |cached_file_path| {id: File.basename(cached_file_path)} }
    end

    def transcripts(poem_id: nil)

      cached_transcripts = get_cached_transcripts(poem_id: poem_id)
      return cached_transcripts unless cached_transcripts.empty?

      files = @service.files("name contains '#{poem_id}*'")

      # files.select { |file| @excluded_files.include?(file.name) || file.name == poem_id }.map fails!
      filtered_files = []

      files.each do |file|
        if !@excluded_files.include?(file.name) && file.name != poem_id && /^#{Regexp.escape(poem_id)}/.match(file.name)
          filtered_files << file
        end
      end

      filtered_files.map do |file|
        get(file)
      end
    end
  end
end
