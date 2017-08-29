
# require File.join(File.dirname(__FILE__), 'swift_poems_project')

module SwiftPoemsProject
  class TeiFileEncoder < TeiEncoder
    def encode(source_id, transcript_id)
      poem_file_path = "#{NB_STORE_PATH}/#{source_id}/#{transcript_id}"
      poem = transcript_id[0..3]

      # Create the poem directory
      poem_dir_path = "#{FILE_STORE_PATH}/poems/#{poem}"

      Dir.mkdir( poem_dir_path ) unless File.exists?( poem_dir_path )
      file_path = poem_file_path
      relative_path = transcript_id

      $stdout.puts "Encoding #{file_path}..."

      nota_bene = SwiftPoemsProject::NotaBene::Document.new file_path
      begin
        transcript = SwiftPoemsProject::Transcript.new nota_bene
      rescue Exception => e
        # $stderr.puts "Failed to encode #{file_path}: #{e.message}"
        # $stderr.puts e.backtrace.join("\n")
        
        # Mail the report
        Mail.deliver do
          from     'noreply@swift.lafayette.edu'
          #        to       'woolleyj@lafayette.edu'
          to       'griffinj@lafayette.edu'
          cc       ['jira@lafayettecollegelibraries.atlassian.net', 'griffinj@lafayette.edu']
          subject  "Swift Poems Project Encoding Report for Transcripts in #{source_id}"
          body     <<END
Dear Sir or Madam,

The following failures were encountered when attempting to encode #{transcript_id}: #{e.message}.

We apologize for this inconvenience, and shall be certain to address the error promptly.  Thank you for your patience.

Sincerely,
Digital Scholarship Services
David B. Skillman Library
Lafayette College
Easton, PA 18042
https://digital.lafayette.edu
END
        end
      else
        # Create the source directory
        source_dir_path = "#{FILE_STORE_PATH}/sources/#{source_id}"
        source_file_path = "#{source_dir_path}/#{relative_path}.tei.xml"

        if File.exists? source_file_path
          File.delete source_file_path
        end

        # $stdout.puts "Encoding #{file_path}..."
        # $stdout.puts "Writing #{source_dir_path}/#{relative_path}.tei.xml"

        # Encode the transcript
        Dir.mkdir( source_dir_path ) unless File.exists?( source_dir_path )
        File.write( source_file_path, transcript.tei.document.to_xml )

        # $stdout.puts "Linking #{poem_dir_path}/#{relative_path}.tei.xml"

        # Create the symlink
        File.symlink( source_file_path, "#{poem_dir_path}/#{relative_path}.tei.xml" ) unless File.exists?( "#{poem_dir_path}/#{relative_path}.tei.xml" )
      end
    end

  end
end
