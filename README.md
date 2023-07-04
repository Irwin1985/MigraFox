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

## Contribuciones
Las contribuciones son bienvenidas. Si tienes alguna idea o mejora para MigraFox, no dudes en abrir un problema o enviar una solicitud de extracción.

## Licencia
MigraFox se distribuye bajo la Licencia MIT. Consulta el archivo LICENSE para obtener más información.

## Contacto
Si tienes alguna pregunta o comentario, puedes ponerte en contacto con el equipo de MigraFox enviando un correo electrónico a rodriguez.irwin@gmail.com.
