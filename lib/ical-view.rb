#!/usr/bin/env ruby

require 'pathname'
require 'ostruct'
require 'optparse'
require 'icalendar'
require 'terminal-table'
require 'colorize'

module ICalViewer

  VERSION = [0, 0, 1]

  DEFAULT_ARGS = {
    debug:    false,
    verbose:  false,
    table:    true,
    files:    [],
  }

  class Parser

    def self.parse options
      args = DEFAULT_ARGS

      args[:files] += ICalViewer::Utils.files options

      opt_parser = OptionParser.new do |opts|

        opts.banner = "Usage: ical-view [options]"

        opts.on("-d", "--debug", "Run with debugging") do
          args[:debug] = true
        end

        opts.on("-v", "--verbose", "Run verbose") do
          args[:verbose] = true
        end

        opts.on("--no-table", "Don't print a table") do
          args[:table] = false
        end

        opts.on_tail("-h", "--help", "Show this message and exit") do
          puts opts
          exit
        end

        opts.on_tail("--version", "Show version") do
          puts ICalViewer::VERSION.join '.'
          exit
        end

      end

      opt_parser.parse! options
      return args
    end

  end

  class Utils

    def initialize opts
      @opts = opts
    end

    def out *strs
      strs.each { |s| puts s } if @opts[:verbose]
    end

    def dbg *strs
      strs.each { |s| puts "\t[DEBUG]:\t#{s}".colorize(color: :yellow, background: :black) } if @opts[:debug]
    end

    def err *strs
      strs.each { |s| puts "\t[ERROR]:\t#{s}".colorize(color: :white, background: :red) }
    end

    def self.files opts
      opts.select { |a| File.file? Pathname.new(a).expand_path }
    end

  end

  def self.run argv
    o = Parser.parse argv
    u = Utils.new o

    o[:files].map { |f| Pathname.new(f).expand_path }.each do |file|
      u.dbg "Opening #{file}"
      f     = File.open file

      u.dbg "Parsing #{file}"
      begin
        cals  = Icalendar.parse f
      rescue ArgumentError => e
        u.err "Cannot parse #{file}"
        u.err e.to_s
        next
      end

      u.dbg "Starting table creation"
      cals.each do |cal|
        tab   = Table.new headings: [ '#', 'tz', 'start', 'end', 'summary' ]

        u.dbg "Creating rows for events"
        cal.events.each do |event|
          u.dbg "Creating row for event: #{event}"
          tab.new_row event
        end

        puts tab.to_s
      end
    end
  end

end

