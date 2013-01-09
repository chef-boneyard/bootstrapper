require 'uri'

module Bootstrapper

  class Config

    attr_accessor :host
    attr_accessor :port

    attr_accessor :user
    attr_accessor :password
    attr_accessor :identity_file

    attr_accessor :gateway
    attr_accessor :paranoid

    def uri=(uri)
      uri = if uri =~ %r{^ssh://}
              uri
            else
              "ssh://#{uri}"
            end
      u = URI.parse(uri)
      @user = u.user unless u.user.nil?
      @host = u.host
    end

    def uri
      u = ""
      u << "#{user}@" unless user.nil?
      u << host
    end

    def to_net_ssh_config
      [
       host,
       user,
       {:password => password, :paranoid => paranoid}
      ]
    end
  end
end
