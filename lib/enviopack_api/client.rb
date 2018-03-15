module EnviopackApi
  class Client
    def initialize(access_token = nil)
      @access_token = access_token || ENV["ENVIPACK_API_TOKEN"]
      @base_uri = "https://api.enviopack.com"
    end

    # GET any available resource with or withoud ID
    # ex.: get("localidades/ID")
    def get(resource, options = nil)
      params = options
      url = "/#{resource}"
      get_response(url, params)
    end

    # GET /resource_name
    def get_resource(resource, options = nil)
      # Prevent resource to be miss spelled
      case resource
      when "correos", "couriers"
        resource_name = "correos"
      when "sucursales"
        resource_name = "sucursales"
      when "provincias", "states"
        resource_name = "provincias"
      when "localidades", "barrios"
        resource_name = "localidades"
      when "paquetes", "packaging", "boxes", "embalaje"
        resource_name = "tipos-de-paquetes"
      when "mis-direcciones", "mi-dreccion", "addresses", "remitiente"
        resource_name = "mis-direcciones"
      when "direcciones-de-envio", "direcciones", "destination"
        resource_name = "direcciones-de-envio"
      else
        resource_name = resource
      end

      # build request
      url = "/#{resource}"
      get_response(url, nil)
    end # get(resource)

    # GET /provincia/ID/validar-codigo-postal
    # returns param 'valido' true or false
    def validate_zipcode(province_id, zipcode)
      zipcode = zipcode.to_i
      url = "/provincia/#{province_id}/validar-codigo-postal"
      query = "codigo_postal=#{zipcode}"
      get_response(url, query)
    end

    # Obtener el costo que abona el VENDEDOR por el envío
    # https://www.enviopack.com/documentacion/cotiza-un-envio
    # Client.get_quote(provincia: "C", codigo_postal: 1407, peso: 0.5, etc: etc)
    def get_quote(options = {})
      ################### Optionals
      # will be removed from code
      # Ej: 20x2x10,20x2x10 indica que se envian 2 paquetes y cada uno tiene 20 cm de alto x 2 cm de ancho x 10 cm de largo.
      paquetes = options[:paquetes]
      correo = options[:correo]  # ID, e.: "oca"

      # For, :despacho & :modalidad
      # - D: retiro por domicilio
      # - S: despacho desde sucursa
      despacho = options[:despacho] || "D"
      modalidad = options[:modalidad] || "D"

      # - N: para el servicio estándar
      # - P: para el servicio prioritario
      # - X: para el servicio express
      # - R: para el servicio de devoluciones
      servicio = options[:servicio] || "N"

      # Shipping dispatch address
      # Client.get('mis-direcciones')
      direccion_envio = options[:direccion_envio]

      # - valor: para ordenar por precio (Default)
      # - horas_entrega: para ordenar por velocidad de envío
      # - cumplimiento: para ordenar por porcentaje de cumplimiento en envios de similares caracteristicas
      # - anomalos: para ordenar por porcentaje de anómalos en envios de similares caracteristicas
      orden_columna = options[:orden_columna]

      # - asc: para orden ascendente (Default)
      # - desc: para orden descendente
      orden_sentido = options[:orden_sentido]

      ################### Required params
      provincia     = options[:provincia] || "C"
      codigo_postal = options[:codigo_postal] || ""
      peso          = options[:peso] || 1.0

      url = "/cotizar/costo"
      query = options.to_query
      get_response(url, query)
    end

    # POST resource
    # https://www.enviopack.com/documentacion/realiza-un-envio
    # req: resource, params
    # Client.post("pedidos", params)
    def post(resource, params)
      case resource
      when "pedidos", "place_order", "new_order" then url = "/pedidos"
      when "envios", "shipping" then url = "/envios"
      else url = "/#{resource}"
      end

      post_request(url, params)
    end

    # Print shipping ticket
    # ID = ticket ID
    # Output: PDF or JPG
    def print_single(id, output = "pdf")
      timenow      = Time.current.strftime("%Y%m%d_-_%H%M")
      resource_url = "#{@base_uri}/envios/#{id}/etiqueta?access_token=#{@access_token}&formato=#{output}"
      begin
        response = RestClient.get resource_url
        send_data(response, :filename => "etiqueta_-_#{timenow}.pdf", :disposition => "attachment", :type => "application/pdf")
      rescue e
        return JSON.parse(e.response, object_class: OpenStruct)
      end
    end

    # Print batch tickets
    # Pass Array of ids: ids = [1,2...9]
    def print_batch(ids)
      timenow      = Time.current.strftime("%Y%m%d_-_%H%M")
      ids_string   = ids.to_csv.delete("\n")
      resource_url = "#{@base_uri}/envios/etiquetas?access_token=#{@access_token}&ids=#{ids_string}"
      begin
        response = RestClient.get resource_url
        send_data(response, :filename => "etiquetas_-_#{timenow}.pdf", :disposition => "attachment", :type => "application/pdf")
      rescue e
        return JSON.parse(e.response, object_class: OpenStruct)
      end
    end


    private
    # GET
    def get_response(url, query = nil)
      query = "&#{query}" if query != nil || query != ""
      resource_url = "#{@base_uri}#{url}?access_token=#{@access_token}#{query}"

      begin
        response = RestClient.get(resource_url)
        result = JSON.parse(response, object_class: OpenStruct)
        return result
      rescue => e
        return JSON.parse(e.response, object_class: OpenStruct)
      end
    end # get_response

    # POST
    def post_request(url, params)
      begin
        resource_url = "#{@base_uri}#{url}?access_token=#{@access_token}"
        response = RestClient.post resource_url, params.to_json, {content_type: :json, accept: :json}
        result = JSON.parse(response, object_class: OpenStruct)
        return result
      rescue => e
        return JSON.parse(e.response, object_class: OpenStruct)
      end
    end # post_request
  end # module EnviopackApi::Client
end
