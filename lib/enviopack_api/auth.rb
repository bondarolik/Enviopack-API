module EnviopackApi
  class Auth
    def initialize(api_key = nil, api_secret = nil)
      @api_key = api_key || ENV["ENVIPACK_API_KEY"]
      @api_secret = api_secret || ENV["ENVIPACK_API_SECRET"]
      @base_uri = "https://api.enviopack.com"
    end

    def auth
      endpoint = "#{@base_uri}/auth"

      begin
        response = RestClient.post endpoint, { "api-key" => @api_key, "secret-key" => @api_secret }
        result   = JSON.parse(response, object_class: OpenStruct)
        return result
      rescue => e
        return JSON.parse(e.response, object_class: OpenStruct)
      end
    end

    def refresh(refresh_token)
      endpoint = "#{@api_url}/token/refresh?refresh_token=#{refresh_token}"

      begin
        response = RestClient.post endpoint, { "api-key" => @api_key, "secret-key" => @api_secret }
        result   = JSON.parse(response, object_class: OpenStruct)
        return result
      rescue => e
        return JSON.parse(e.response, object_class: OpenStruct)
      end
    end
  end # EnviopackApi::Auth
end
