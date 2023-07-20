# MigraFox

MigraFox es una biblioteca escrita en Visual FoxPro 9.0 que facilita la migración de estructuras y datos a servidores de bases de datos como SQL Server, MariaDB, MySQL, Firebird, entre otros. Además, expone una API para crear conexiones y enviar consultas SQL que se convierten en cursores actualizables o de solo lectura.

## Características principales

Migración sencilla de estructuras y datos a servidores de bases de datos.
Creación de conexiones a diferentes motores de bases de datos.
Creación de cursores actualizables o de solo lectura.
Soporte para SQL Server, MySQL y MariaDB.

## Instalación

Clona este repositorio en tu entorno de desarrollo local.

```bash
git clone https://github.com/tu-usuario/MigraFox.git
```

Abre VFP y carga la librería:
```xBase
SET PROCEDURE TO "c:\ruta\MigraFox.prg" ADDITIVE
```

## Uso

Crear una instancia

```xBase
LOCAL loDB
loDB = CreateObject("MYSQL")
```

## Establecer la conexión

```xBase
loDB.cDatabase = "northwind"
loDB.cDriver = "MySQL ODBC 5.1 Driver"
loDB.cUser = "root"
loDB.cPassWord = "1234"

IF loDB.connect()
   ? "Conexión exitosa"
ELSE
   ? "Error en la conexión"
ENDIF
```

## Abrir una vista actualizable
```xBase
loDB.use("africa")
```

## Realizar operaciones CRUD en la vista
```xBase
// Insertar un nuevo registro
USE africa
APPEND BLANK
REPLACE field1 WITH "valor1"

loDB.save()
```

## Cerrar una vista
```xBase
loDB.close()
```

## Cambiar de base de datos
```xBase
loDB.changeDB("northwind2")
```

## Ejecutar una consulta SQL personalizada

```xBase
lcSQLCommand = "SELECT * FROM customers WHERE country = 'Mexico'"
loDB.SQLExec(lcSQLCommand, "miCursor")
```

## Migrar estructuras y datos
```xBase
// Migrar todos los archivos DBF dentro de una carpeta
loDB.migrate("c:\ruta\carpeta\")
```

```xBase
// Migrar un archivo DBF específico
loDB.migrate("c:\ruta\archivo.dbf")
```

## Migrar una tabla usando el script interno de MigraFox

MigraFox cuenta con un script interno que se ejecuta mediante un intérprete diseñado para facilitar las migraciones de bases de datos y la gestión de esquemas en múltiples lenguajes de programación. El objetivo principal es proporcionar una sintaxis intuitiva y unificada para definir y modificar estructuras de bases de datos, permitiendo a los desarrolladores evolucionar sus esquemas de manera sencilla y controlada.

## Inspiración en YAML

La sintaxis del script está inspirada en YAML con algunas adaptaciones para satisfacer las necesidades específicas de la gestión de esquemas de bases de datos. La sintaxis se ha simplificado y se han agregado atributos personalizados para definir campos, tablas, relaciones y otros elementos de manera intuitiva.

## Características

- Sintaxis simplificada y legible para definir y gestionar esquemas de bases de datos.
- Soporte multiplataforma para lenguajes de programación populares.
- Migración eficiente y transformación de estructuras y datos de bases de datos.
- Actualización de estructuras a través de ficheros de scripting (.tmg)
- Control de versiones y seguimiento de cambios en los esquemas.
- Integración con varios sistemas de gestión de bases de datos.

## Ejemplos

A continuación se muestra un ejemplo completo que refleja toda la sintaxis del script.

```yaml
# Definición de la tabla "Clientes"
- table:
  name: Clientes
  description: "Tabla que almacena información de los clientes."
  fields:
    - name: id
      type: int
      size: 11
      primaryKey: true
    - name: nombre
      type: varchar
      size: 100
      index: true
    - name: direccion
      type: varchar
      size: 200

# Definición de la tabla "Categorias"
- table:
  name: Categorias
  description: "Tabla que almacena información de las categorías de productos."
  fields:
    - name: id
      type: int
      size: 11
      primaryKey: true
    - name: nombre
      type: varchar
      size: 100
      index: true

# Definición de la tabla "Productos"
- table:
  name: Productos
  description: "Tabla que almacena información de los productos."
  fields:
    - name: id
      type: int
      size: 11
      primaryKey: true
    - name: nombre
      type: varchar
      size: 100
      index: true
    - name: precio_unitario
      type: float
      size: 8
      decimal: 2
    - name: categoria_id
      type: int
      size: 11
      foreignKey:
        fkTable: Categorias
        fkField: id
        onDelete: setnull
        onUpdate: restrict

# Definición de la tabla "Facturas"
- table:
  name: Facturas
  description: "Tabla que almacena información de las facturas."
  fields:
    - name: id
      type: int
      size: 11
      primaryKey: true
    - name: cliente_id
      type: int
      size: 11
      foreignKey:
        fkTable: Clientes
        fkField: id
        onDelete: setnull
        onUpdate: restrict
    - name: fecha
      type: date
  composed:
    - columns: [cliente_id, fecha desc]
      unique: true

# Definición de la tabla "Pedidos"
- table:
  name: Pedidos
  description: "Tabla que almacena información de los pedidos."
  fields:
    - name: id
      type: int
      size: 11
      primaryKey: true
    - name: cliente_id
      type: int
      size: 11
      foreignKey:
        fkTable: Clientes
        fkField: id
        onDelete: setnull
        onUpdate: restrict
    - name: fecha
      type: date
    composed:
      - columns: [cliente_id, fecha desc]
        unique: true

# Definición de la tabla "DetallesFactura"
- table:
  name: DetallesFactura
  description: "Tabla que almacena el detalle de las facturas."
  fields:
    - name: id
      type: int
      size: 11
      primaryKey: true
    - name: factura_id
      type: int
      size: 11
      foreignKey:
        fkTable: Facturas
        fkField: id
        onDelete: cascade
        onUpdate: restrict
    - name: producto_id
      type: int
      size: 11
      foreignKey:
        fkTable: Productos
        fkField: id
        onDelete: setnull
        onUpdate: restrict
    - name: cantidad
      type: int
      size: 11
    - name: precio_unitario
      type: float
      size: 8
      decimal: 2
    composed:
      - columns: [factura_id, producto_id]
        unique: true

# Definición de la tabla "Empleados"
- table:
  name: Empleados
  description: "Tabla que almacena información de los empleados."
  fields:
    - name: id
      type: int
      size: 11
      primaryKey: true
    - name: nombre
      type: varchar
      size: 100
    - name: cargo
      type: varchar
      size: 50

# Definición de la tabla "Proveedores"
- table:
  name: Proveedores
  description: "Tabla que almacena información de los proveedores."
  fields:
    - name: id
      type: int
      size: 11
      primaryKey: true
    - name: nombre
      type: varchar
      size: 100
      index: true
    - name: direccion
      type: varchar
      size: 200

# Definición de la tabla "Compras"
- table:
  name: Compras
  description: "Tabla que almacena información de las compras."
  fields:
    - name: id
      type: int
      size: 11
      primaryKey: true
    - name: proveedor_id
      type: int
      size: 11
      foreignKey:
        fkTable: Proveedores
        fkField: id
        onDelete: setnull
        onUpdate: restrict
    - name: empleado_id
      type: int
      size: 11
      foreignKey:
        fkTable: Empleados
        fkField: id
        onDelete: setnull
        onUpdate: restrict
    - name: fecha
      type: date
    composed:
      - columns: [proveedor_id, fecha desc]
        unique: true

# Definición de la tabla "DetallesCompra"
- table: 
  name: DetallesCompra
  description: "Tabla que almacena los detalles de las compras."
  fields:
    - name: id
      type: int
      size: 11
      primaryKey: true
    - name: compra_id
      type: int
      size: 11
      foreignKey:
        fkTable: Compras
        fkField: id
        onDelete: cascade
        onUpdate: restrict
    - name: producto_id
      type: int
      size: 11
      foreignKey:
        fkTable: Productos
        fkField: id
        onDelete: setnull
        onUpdate: restrict
    - name: cantidad
      type: int
      size: 11
    - name: precio_unitario
      type: float
      size: 8
      decimal: 2
    composed:
      - columns: [compra_id, producto_id]
        unique: true
```

## Contribuciones
Las contribuciones son bienvenidas. Si tienes alguna idea o mejora para MigraFox, no dudes en abrir un problema o enviar una solicitud de extracción.

## Licencia
MigraFox se distribuye bajo la Licencia MIT. Consulta el archivo LICENSE para obtener más información.

## Contacto
Si tienes alguna pregunta o comentario, puedes ponerte en contacto con el equipo de MigraFox enviando un correo electrónico a rodriguez.irwin@gmail.com.
