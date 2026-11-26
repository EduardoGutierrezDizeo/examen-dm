# cuenta

Aplicación Flutter académica de administración de videojuegos. El catálogo y el detalle viven bajo `/admin/videojuegos` y los datos se leen directamente de una base de datos MySQL de XAMPP.

## Base de datos

La app usa `mysql_client` para conectarse por TCP a MySQL/MariaDB de XAMPP en `127.0.0.1:3306` (base `examen_videojuegos`, usuario `root`, contraseña `root123`, sin TLS). `mysql_client` no autentica contra cuentas con contraseña vacía, por eso `root` debe tener contraseña; configúrala con:

```cmd
"C:\xampp\mysql\bin\mysql.exe" -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root123'; FLUSH PRIVILEGES;"
```

Después de eso, el cliente de MySQL necesita `-proot123`. Al usar una conexión TCP directa, **no funciona en web/Chrome**: ejecútala en escritorio Windows o en móvil con el servidor accesible.

El script `sql/examen_videojuegos.sql` crea las tablas `usuario`, `videojuego` y `dlc` y las llena con datos iniciales (videojuegos reales y sus DLC).

## Cómo ejecutar

1. Encender Apache y MySQL en XAMPP.
2. Asignar la contraseña a `root` (comando de la sección anterior) e importar `sql/examen_videojuegos.sql` desde phpMyAdmin (`http://localhost/phpmyadmin`) o con `"C:\xampp\mysql\bin\mysql.exe" -u root -proot123 < sql\examen_videojuegos.sql` en CMD.
3. `flutter pub get`
4. `flutter run -d windows` (la ventana se abre sola; también puedes ejecutar directamente `build\windows\x64\runner\Debug\cuenta.exe` después de compilar).

## Usuarios de prueba

| Usuario | Contraseña |
|---|---|
| `admin` | `admin123` (ciudad: Ocaña) |
| `demo` | `demo123` |

Las contraseñas se guardan en la tabla `usuario` como hash SHA-256 (`CHAR(64)`), calculado con `SHA2(..., 256)`. El inicio de sesión compara el hash de la contraseña escrita y guarda el id del usuario en la clave `token` de `FlutterSecureStorage`.

## Estructura relevante

- `lib/database/` — `DatabaseHelper`: singleton con la conexión MySQL cacheada.
- `lib/model/` — `UsuarioModel`, `VideojuegoModel` y `VideojuegoDlc`, con `fromJson` defensivo.
- `lib/repository/` — `UsuarioRepositorio` y `VideojuegoRepositorio`: consultas parametrizadas a MySQL.
- `lib/services/` — `AuthService`, `ProfileService` y `VideojuegosService`: errores traducidos a `ApiException` con mensajes en español.
- `sql/` — script de creación de la base y datos iniciales.

El tema claro/oscuro se gestiona con Riverpod, la navegación con `go_router` y el estado de cada pantalla con `setState`.
