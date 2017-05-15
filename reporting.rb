#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

module SwiftPoemsProject
  module Reporting

    class Report

      attr :rows

      # all starting with R112D257 and running to Z717-V82- [about 300 from FOXON]
      INCLUDED_FILE_NAMES = [
                             'X44-580B',
                             '745-268R',
                             '553-100I',
                             '866-410A',
                             'J0171701',
                             '609-33IA',
                             '432A54XA',
                             '334-24JK',
                             '274-21VD',
                             'X08-25D3',
                             '773-INT8',
                             '475-30L2',
                             'Y48A33LK',
                             '878-#1L1',
                             '610-33IB',
                             '611-33GG',
                             '723-28L5',
                             '!W75%0L1',
                             '250-21L5',
                             '102-0151',
                             '102-0152',
                             'S05321WD',
                             '239-960A',
                             '553B040B',
                             'Y20-684B',
                             '825-250A',
                             'Z67239D1',
                             'Z770035Y',
                             '601-46L-',
                             '!W2208G1',
                             'J03055H1',
                            ]
      
      EXCLUDED_DIR_NAMES = [
                     "\\",
                     '4DOS750',
                     'BIBLS',
                     'CASE',
                     'DESCRIBE',
                     'EDIT',
                     'FAIRBROT',
                     'FAULKNER',
                     'HW37',
                     'INSTALL',
                     'MSSOURCE',
                     'NB',
                     'NEWDOS',
                     'POEMCOLL',
                     'PRSOURCE',
                     'STEMMAS',
                     'TEI-SAMP',
                     'vDos',
                     'XML-TEST',
                     'incoming',
                     ]

      EXCLUDED_FILE_PREFIXES = [
                                'proof',
                                '!W27',
                                '!W28',
                                'Dosbox',
                                'tocheck.',
                                'tochk.',
                               ]

      EXCLUDED_FILE_SUFFIXES = [
                                '.bak',
                                '.tmp',
                                '.doc',
                                '.ORI',
                               ]

      EXCLUDED_FILE_NAMES = [
                             'readme',
                             'another',
                             'tocheck',
                             'TOCHECK',
                             'SOURCES',
                             'PUMP',
                             'J0311801',
                             'J0311851',
                             'J0311871',
                             'J03155H1',
                             '!W61500B',
                            ]

      EXCLUDED_FILE_SIZE_MIN = 900

      def initialize(file_store_path)
        @file_store_path = file_store_path
        @rows = []

        @files = Dir.glob(File.join(file_store_path, '**', '*')).select do |file_path|

          dir_path = File.dirname(file_path)
          # dir_name = File.basename(dir_path)

          file_path_segments = file_path.gsub("#{file_store_path}/", '')
          dir_name = file_path_segments.split('/').first

          file_name = File.basename(file_path)

          has_excluded_dir_name = EXCLUDED_DIR_NAMES.include?(dir_name)
          exceeds_min_file_size = File.stat(file_path).size >= EXCLUDED_FILE_SIZE_MIN
          has_excluded_file_name = EXCLUDED_FILE_NAMES.include?(file_name)
          has_excluded_prefix = EXCLUDED_FILE_PREFIXES.map { |prefix| !/^#{Regexp.escape(prefix)}/.match(file_name).nil? }.reduce(:|)
          has_excluded_suffix = EXCLUDED_FILE_SUFFIXES.map { |suffix| !/#{Regexp.escape(suffix)}$/.match(file_name).nil? }.reduce(:|)

          INCLUDED_FILE_NAMES.include?(file_name) || !( file_name == dir_name || File.directory?(file_path) || EXCLUDED_DIR_NAMES.include?(dir_name) || !exceeds_min_file_size || EXCLUDED_FILE_NAMES.include?(file_name) || has_excluded_prefix || has_excluded_suffix  )
        end
      end

      def generate(tei_store_path)
        @files.each do |file_path|

          dir_path = File.dirname(file_path)

          file_path_segments = file_path.gsub("#{@file_store_path}/", '')
          dir_name = file_path_segments.split('/').first

          file_name = File.basename(file_path)
          tei_file_path = File.join(tei_store_path, 'sources', dir_name, "#{file_name}.tei.xml")

          if File.exists?(tei_file_path)
            tei_file_uri = "file://#{tei_file_path}"
            tei_file_stat = File.stat(tei_file_path)
            
            @rows << [file_name, dir_name, 'Encoded', tei_file_uri, tei_file_stat.mtime]
          else
            @rows.unshift([file_name, dir_name, 'Not Encoded', 'Not Encoded', 'Not Encoded'])
          end
        end

        @rows
      end
    end
  end
end
