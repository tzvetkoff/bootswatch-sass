#!/usr/bin/env ruby

require 'rubygems'
require 'fileutils'
require 'optparse'

class Bumper
  THEMES = %w[
    amelia cerulean cosmo cyborg darkly
    flatly journal lumen paper readable
    sandstone simplex slate spacelab superhero
    united yeti
  ]

  Exception = Class.new(::Exception)

  class << self
    attr_accessor :clean, :pull, :checkout, :bs_tag, :bw_tag, :version, :verbose, :root, :tmp, :bs, :bw

    #
    # The bumper itself
    #

    def bump!(args = ARGV.dup)
      initialize!(args)

      update_sources! if @pull
      checkout_tags! if @checkout
      cleanup! if @clean

      do_fonts!
      do_images!
      do_javascripts!
      do_stylesheets!
      do_themes!

      write_version!
    end

    private

    #
    # Worker functions
    #

    def initialize!(args)
      @clean = true
      @pull = true
      @checkout = true
      @verbose = false

      option_parser = OptionParser.new do |opts|
        opts.banner = "Usage: #{$0} [options] <bootstrap-tag> [bootswatch-tag] [version]"

        opts.on('-p', '--skip-pull', 'Don\'t do `git pull`') do
          @pull = false
        end
        opts.on('-c', '--skip-checkout', 'Don\'t do `git checkout`') do
          @checkout = false
        end
        opts.on('-s', '--skip-clean', 'Don\'t clean the assets directory') do
          @clean = false
        end
        opts.on('-v', '--verbose', 'Print lots of stuff to STDOUT') do
          @verbose = true
        end
      end
      args = option_parser.parse!(args)

      @bs_tag = args[0]
      @bw_tag = args[1] || bs_tag

      unless @bs_tag
        raise Exception, option_parser.help
      end

      @version = args[2] || bs_tag.gsub(/[^0-9.]/, '')

      @root = File.expand_path('..', __FILE__)
      @tmp = "#{root}/tmp"
      @bs = "#{tmp}/bootstrap-sass"
      @bw = "#{tmp}/bootswatch"
    end

    def update_sources!
      # Clone or pull bootstrap
      if File.directory?(bs)
        cd bs do
          git :checkout, 'master'
          git :pull
        end
      else
        cd tmp do
          git :clone, 'git@github.com:twbs/bootstrap-sass.git', 'bootstrap-sass'
        end
      end
      # Clone or pull bootswatch
      if File.directory?(bw)
        cd bw do
          git :checkout, 'gh-pages'
          git :pull
        end
      else
        cd tmp do
          git :clone, 'git@github.com:thomaspark/bootswatch.git', 'bootswatch'
        end
      end
    end

    def checkout_tags!
      # Checkout in bootstrap
      cd bs do
        git :checkout, bs_tag
      end
      # Checkout in bootswatch
      cd bw do
        git :checkout, bw_tag
      end
    end

    def cleanup!
      # Remove everything!
      rm "#{root}/assets" if clean
    end

    def do_fonts!
      Dir["#{bs}/assets/fonts/**/*"].each do |src|
        # Skip non-existing files
        next unless File.file?(src)

        # Copy the file
        dst = src.dup
        dst["#{bs}/assets/fonts/"] = "#{root}/assets/fonts/"
        cp(src, dst)
      end
    end

    def do_images!
      Dir["#{bs}/assets/images/**/*"].each do |src|
        # Skip non-existing files
        next unless File.file?(src)

        # Copy the file
        dst = src.dup
        dst["#{bs}/assets/images/"] = "#{root}/assets/images/"
        cp(src, dst)
      end
    end

    def do_javascripts!
      Dir["#{bs}/assets/javascripts/**/*"].each do |src|
        # Skip non-existing files
        next unless File.file?(src)

        # Copy the file
        dst = src.dup
        dst["#{bs}/assets/javascripts/"] = "#{root}/assets/javascripts/"
        cp(src, dst)
      end

      # The sprockets file is the one we need as we only support asset pipeline
      cp("#{root}/assets/javascripts/bootstrap-sprockets.js", "#{root}/assets/javascripts/bootstrap.js")
      rm("#{root}/assets/javascripts/bootstrap-sprockets.js")
    end

    def do_stylesheets!
      Dir["#{bs}/assets/stylesheets/**/*"].each do |src|
        # Skip non-existing files and helpers - we only support asset pipeline / sprockets
        next unless File.file?(src)
        next if /mincer|sprockets|compass/ =~ src

        # Copy the file
        dst = src.dup
        dst["#{bs}/assets/stylesheets/"] = "#{root}/assets/stylesheets/"
        cp(src, dst)

        # Replace helper functions with asset pipeline ones
        sed(dst, /twbs-font-path/, 'font-path')
        sed(dst, /twbs-image-path/, 'image-path')
      end
    end

    def do_themes!
      THEMES.each do |theme|
        # Skip removed themes
        next unless File.directory?("#{bw}/#{theme}")

        # Create the sub-directory for the includes
        FileUtils.mkdir_p("#{root}/assets/stylesheets/#{theme}")

        # Copy the variables file
        cp("#{bw}/#{theme}/_variables.scss", "#{root}/assets/stylesheets/#{theme}/_variables.scss")
        # Fix the $icon-font-path
        sed("#{root}/assets/stylesheets/#{theme}/_variables.scss", /^\$icon-font-path:\s*"(.*)";$/, '$icon-font-path:          "bootstrap/" !default;')
        # Copy the bootswatch file
        cp("#{bw}/#{theme}/_bootswatch.scss", "#{root}/assets/stylesheets/#{theme}/_bootswatch.scss")

        # Create the theme file
        contents = <<-EOT
@import "#{theme}/variables";
@import "bootstrap";
@import "#{theme}/bootswatch";
        EOT
        File.write("#{root}/assets/stylesheets/_bootstrap-#{theme}.scss", contents)
      end
    end

    def write_version!
      # Create the version file
      contents = <<-EOT
module BootswatchSass
  VERSION = '#{version}'
end
      EOT

      File.write("#{root}/lib/bootswatch-sass/version.rb", contents)
    end

    #
    # Helper functions
    #

    def cd(dir)
      pwd = Dir.getwd
      Dir.chdir(dir)

      if block_given?
        yield
        Dir.chdir(pwd)
      end
    end

    def cp(src, dst)
      puts "#{src} => #{dst}" if @verbose
      dir = File.dirname(dst)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      FileUtils.cp(src, dst)
    end

    def rm(file)
      puts "rm -rf #{file}" if @verbose
      FileUtils.rm_rf(file)
    end

    def git(*args)
      args = args.map(&:to_s)
      puts "$ git #{args.join(' ')}" if @verbose
      system 'git', *args
    end

    def sed(file, search, replace = nil, &block)
      puts "sed s/#{Regexp === search ? search.source : search}/#{block_given ? replace : '...'}/g" if @verbose

      contents = File.read(file)

      if block_given?
        contents.gsub!(search, &block)
      else
        contents.gsub!(search, replace)
      end

      File.write(file, contents)
    end
  end
end

#
# Bump, bump, bump!
#

begin
  Bumper.bump!
rescue Bumper::Exception
  puts $!.message
end
