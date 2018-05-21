# EnviopackApi

## Instalación

Agregá esta linea en tu Ruby (Ruby on Rails) applicación:

```ruby
# para la última versión
gem 'enviopack_api', :git => "git@github.com:bondarolik/enviopack-api.git"
```

Ejecutá bundler:

    $ bundle

O actualiza (instala) independientemente:

    $ gem install enviopack_api

## Uso

> Todos los metodos devuelven objetos en OpenStruct. Por lo cual, los response que deberias usar son: result.id (result.code, etc.)

Primero deberias leer documentación oficial y [consideraciones iniciales](https://www.enviopack.com/documentacion/consideraciones-iniciales) de Enviopack.

### Access & Refresh tokens

En segunda instancia seguí los pasos para obtener los API ID & KEY en tu panel de control en Enviopack y luego el `access_token` o `refresh_token`:

```ruby
# Obtener access token
irb: auth = EnviopackApi::Auth.new(api_key, api_secret).auth

# Actualizar tokens:
# no olvides a grabarlos en tu base de datos
irb: refresh = EnviopackApi::Auth.new(api_key, api_secret).refresh(refresh_token)
```


Para usar API en general necesitaras pocos metodos y muchos parametros. Los principales y testeados en esta GEMa estan descriptos a continuación.

Una vez obtenido access_token podeis comenzar a trabajar con API. Simplemente crea una conexión con cliente:

```ruby
client = EnviopackApi::Client.new(auth.token)

# presta atención que va sin trailing slash en adelante
client.get("pedidos/id")
```


### Metodos principales GET

Para obtener datos de pracitcametne cualquier recurso:

```ruby
client.get("resource")
```

Recursos disponibles en el momento de publicación:

    + correos
    + sucursales
    + provincias
    + localidades
    + tipos-de-paquetes
    + mis-direcciones
    + direcciones-de-envio

Mas información sobre cada uno y sus usos encuentra en [Documentación correspondiente](https://www.enviopack.com/documentacion/correos)

Para obtener datos de algún recurso especifico podeis utilizar siguiente metodo:

```ruby
client.get_resource("resource")
```

### Validación de Código Postal

Existe un metodo especial para validad `código postal` . El parametro `provincia_id` es un **iso_code** sin prefijo **"AR-"**

```ruby
# /provincia/ID/validar-codigo-postal
client.validate_zipcode(province_id, zipcode)
# => {"valido":true}
```

Mas info sobre [ISO 3166](https://www.iso.org/obp/ui/#iso:code:3166:AR). Sugerimos tenerlos en agluna tabla de tu base de datos.

### Cotizar un envío

Basicamente se puede hacer un request por `EnviopackApi::Client.get`, pero también se puede usar este metodo:

```ruby
# https://www.enviopack.com/documentacion/cotiza-un-envio
quote = client.get_quote(params)
```

Existen parametros obligatorios y opcionales. Ten cuidado con esto.

### Crear un POST

```ruby
client.post("resource")
```

Atención con lo que mandas. Originalmente, los dos **POST** que vas hacer son a "pedidos" y "envios". Pero, también podeis mandar "place_order" o "shipping". No hay problema en esto.

```ruby
      case resource
      when "pedidos", "place_order", "new_order" then url = "/pedidos"
      when "envios", "shipping" then url = "/envios"
      else url = "/#{resource}"
      end
```

### Eliminar un (o varios) envios

El envio debe estar en borrador y **no estar procesado**

```ruby
# comma separated list
# ids = array_of_ids.join(",")
# => 1,2,3....xxx
client.delete(ids)
```

Atención con lo que mandas. Originalmente, los dos **POST** que vas hacer son a "pedidos" y "envios". Pero, también podeis mandar "place_order" o "shipping". No hay problema en esto.

```ruby
      case resource
      when "pedidos", "place_order", "new_order" then url = "/pedidos"
      when "envios", "shipping" then url = "/envios"
      else url = "/#{resource}"
      end
```



### Impresión de etiquetas de envío

> Aún no testeado en GEMa en producción. En localhost anda bien, pero sin confirmación todavía.


```ruby
# imprimir etiqueta particular
client.print_single(id, "pdf")

# imprimir varias etiquetas
client.print_batch(ids)
```

En BATCH se imprime únicamente PDF. Tienes que pasar el Array de IDS. Por ejemplo:

```ruby
ids = [1,2,3,4]
```

La GEMa lo convierte en formato que corresponde. Como resultado vas a recibir un PDF por el medio de siguiente función ruby:

```ruby
send_data(response, :filename => "etiquetas_-_#{timenow}.pdf", :disposition => "attachment", :type => "application/pdf")
```

De la misma manera podes crear un request GET y procesar por separado la etiqueta.



## Development

No esta hecho **SPLIT DE PAGO** y **NOTIFICACIONES**. No se sabe cuando y si se va a realizarse en esta GEMa.

## Contributing

Sea bienvenido de forkear, modificar y hacer sugerencias. Postea bugs y requests en ISSUES explicando lo que te paso paso a paso para comprender mejor.

## License

GEMa hecha en laboratorios de desarrollo [POW](http://pow.la/)

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the EnviopackApi project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/enviopack_api/blob/master/CODE_OF_CONDUCT.md).
