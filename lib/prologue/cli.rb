require 'thor'
require 'thor/actions'
require 'active_support/secure_random'

module Prologue
  class CLI < Thor
    include Thor::Actions

    desc "new [app]", "Create a new Rails 3 application"
    long_desc <<-D
      Prologue will ask you a few questions to determine what features you
      would like to generate. Based on your answers it will setup a new Rails 3 application.
    D
    method_option :auth, :type => :boolean, :default => true, :banner =>
      "Sets up devise for authentication."
    method_option :roles, :type => :boolean, :default => true, :banner =>
      "Sets up cancan for authorization with roles."
    method_option :admin, :type => :boolean, :default => true, :banner =>
      "Sets up very basic admin"
    method_option :confirmable, :type => :boolean, :default => true, :banner =>
      "Use devise confirmable module"
    method_option :token_authenticatable, :type => :boolean, :default => true, :banner =>
      "Use devise token_authenticatable module"
    method_option :registerable, :type => :boolean, :default => false, :banner =>
      "Use devise registerable module"
    
    def new(project)
      opts = options.dup

      # Can't build an admin or roles without devise
      if !opts[:auth]
        opts[:admin] = false;
        opts[:roles] = false;
      end

      # Env vars used in our template
      ENV['PROLOGUE_AUTH']  = "true" if opts[:auth]
      ENV['PROLOGUE_ADMIN'] = "true" if opts[:admin]
      ENV['PROLOGUE_ROLES'] = "true" if opts[:roles]
      ENV['PROLOGUE_CONFIRMABLE']  = "true" if opts[:confirmable]
      ENV['PROLOGUE_TOKEN_AUTHENTICATABLE'] = "true" if opts[:token_authenticatable]
      ENV['PROLOGUE_REGISTERABLE'] = "true" if opts[:registerable]
      ENV['PROLOGUE_USER_NAME'] = git_user_name if opts[:admin]
      ENV['PROLOGUE_USER_EMAIL'] = git_user_email if opts[:admin]
      ENV['PROLOGUE_USER_PASSWORD'] = user_password if opts[:admin]

      exec(<<-COMMAND)
        rails new #{project} \
          --template=#{template} \
          --skip-test-unit \
          --skip-prototype
      COMMAND
    end

    desc "version", "Prints Prologue's version information"
    def version
      say "Prologue version #{Prologue::VERSION}"
    end
    map %w(-v --version) => :version

    private

    def template
      File.expand_path(File.dirname(__FILE__) + "/../../templates/bootstrap.rb")
    end

    def git_user_name
      `git config --global user.name`.chomp.gsub('"', '\"') || "Quick Left"
    end

    def git_user_email
      `git config --global user.email`.chomp || "me@me.com"
    end

    def user_password
      ActiveSupport::SecureRandom.base64(8)
    end

  end
end