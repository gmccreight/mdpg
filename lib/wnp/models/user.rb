module Wnp::Models

  class User < Base

    attr_accessor :name, :email, :salt, :hashed_password, :access_token

    def self.authenticate email, password
      user = self.find_by_index :email, email
      return nil if ! user
      if user.password_authenticates?(password)
        return user
      end
      nil
    end

    def create opts = {}
      @password = opts[:password]
      opts.delete :password
      super opts
    end

    def password= password
      @password = password
    end

    def save
      ensure_access_token()
      ensure_salt()
      possibly_create_hashed_password()
      super
    end

    def password_authenticates? password
      self.hashed_password == hash_this_password(password)
    end

    private

      def unique_id_indexes
        [:email, :access_token]
      end

      def possibly_create_hashed_password
        if @password
          self.hashed_password = hash_this_password(@password)
        end
      end

      def hash_this_password(password)
        Digest::SHA1.hexdigest(password + self.salt)
      end

      def ensure_salt
        if ! self.salt
          self.salt = rand_string_of_length 32
        end
      end

      def ensure_access_token
        if ! self.access_token
          self.access_token = rand_string_of_length 32
        end
      end

      def rand_string_of_length length
        (0...length).map{(65+rand(26)).chr}.join.downcase
      end

      def validates?
      end

      def get_data_prefix
        "userdata"
      end

  end

end
