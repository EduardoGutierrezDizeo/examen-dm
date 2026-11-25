# Documentación técnica — Proyecto `clase` (integración de SQLite del profesor)

> **Estado del documento:** 25 de noviembre de 2026.
> **Alcance:** únicamente el proyecto Flutter anidado en `C:\Users\tutov\Desktop\Examen\clase`. Es un proyecto **independiente** del proyecto raíz `cuenta` (tiene su propio `pubspec.yaml`, `pubspec.lock`, `.metadata`, plataformas nativas y `.idea`).
> **Objetivo:** dejar constatada **la forma exacta en que el profesor integró una base de datos SQLite en Flutter** (archivos, capas, estilo de código, inicialización, operaciones y lagunas), para que una IA pueda replicarla en el proyecto raíz sin inventar una arquitectura distinta.
> **Formato:** este archivo está en Markdown (`.md`).

---

## 0. Cómo usar esta documentación

1. **1–3:** identidad, estructura y arquitectura de la BD.
2. **4–7:** código literal de las cuatro piezas (`main.dart`, `DatabaseHelper`, `UsuarioModel`, `UsuarioRepositorio`) y qué hace cada una.
3. **8–9:** estilo de programación del profesor e integración nativa del plugin.
4. **10:** estado real del proyecto (errores, código incompleto, test de plantilla).
5. **11–13:** traslado paso a paso al proyecto raíz, plantillas y checklist.
6. **14:** diferencias entre ambos proyectos y reglas para decidir qué se copia y qué se adapta.

**Regla clave:** el patrón del profesor es **singleton + getter lazy + repositorio delgado + modelo con `fromJson`**. No sustituirlo por `Provider`, Drift, Isar ni `sqflite_common_ffi` al replicarlo.

---

## 1. Identidad y dependencias del proyecto `clase`

### 1.1 `pubspec.yaml` (valores relevantes)

```yaml
name: clase
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.14.0

dependencies:
  flutter:
    sdk: flutter
  material_ui: ^1.1.0
  cupertino_icons: ^1.0.8
  sqflite: ^2.4.6        # <-- base de datos SQLite
  path: ^1.9.1           # <-- join() para construir la ruta del archivo .db

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
```

- `sqflite` y `path` son **las dos únicas dependencias nuevas** respecto a un proyecto Flutter recién creado; son la base de toda la integración.
- `material_ui: ^1.1.0` se importa en `main.dart` y en el test, pero en el código actual **no se usa ningún widget de ese paquete** (solo `MaterialApp` y `Text` de Flutter).
- El SDK declarado (`^3.14.0`) es **más nuevo** que el del proyecto raíz (`^3.9.2`). Al portar el código al raíz, el código del profesor es compatible, pero no al revés (p. ej. el raíz usa `Color.withValues`, disponible en Flutter reciente).

### 1.2 Archivos de configuración propios

- `clase/pubspec.lock` con `sqflite 2.4.6`, `sqflite_android 2.4.6`, `sqflite_common 2.5.17`, `sqflite_darwin 2.4.6`, `sqflite_platform_interface 2.4.4`.
- `clase/.flutter-plugins-dependencies` registra los plugins nativos (ver §9).
- `clase/.dart_tool/package_config.json` existe, pero **apunta a rutas de otra máquina** (`C:\Users\SCIS2PC18\AppData\Local\Pub\Cache\...`), por lo que hoy no resuelve dependencias en este equipo sin `flutter pub get`.
- `clase/analysis_options.yaml` con `include: package:flutter_lints/flutter.yaml` y exclusión explícita de `build/**`, `android/**`, `ios/**`, `web/**`, `windows/**`, `macos/**`, `linux/**`.
- `clase/.idea/runConfigurations/main_dart.xml` y `clase/clase.iml`: configuración de IDE, no lógica de negocio.
- `clase/README.md` sigue siendo el template por defecto ("A new Flutter project"), no documenta la BD.

---

## 2. Estructura de carpetas del proyecto `clase`

```
clase/
├─ pubspec.yaml / pubspec.lock / analysis_options.yaml / .metadata
├─ .flutter-plugins-dependencies
├─ .idea/ , .dart_tool/ , clase.iml
├─ android/ ios/ web/ linux/ macos/ windows/    (generado por Flutter)
├─ test/
│  └─ widget_test.dart        test de plantilla del contador (NO refleja la app; ver §10)
└─ lib/
   ├─ main.dart                arranque: ensureInitialized + abrir BD + runApp
   ├─ database/
   │  └─ database_helper.dart  singleton de SQLite, creación de la tabla
   ├─ model/
   │  └─ usuario_model.dart    entidad UsuarioModel + fromJson
   ├─ repository/
   │  └─ usuario_repositorio.dart  operaciones INSERT / SELECT
   ├─ handler/                 ⚠ carpeta vacía en el snapshot (posibles controladores futuros)
   └─ presentation/            ⚠ carpeta vacía en el snapshot (posibles pantallas futuras)
```

**Observación importante:** en el estado actual del proyecto **no hay widgets de UI para la BD** (`presentation/` y `handler/` están vacías). `main.dart` termina en un `Text("<df")` de depuración. La integración que hay que copiar es la capa de datos, no una pantalla.

---

## 3. Arquitectura de la base de datos en 4 piezas

```
main()
  │ WidgetsFlutterBinding.ensureInitialized()
  │ await DatabaseHelper().database          ← fuerza la apertura antes de runApp
  ▼
DatabaseHelper  (singleton)  ──> getDatabasesPath() + join(..., "usuarios.db")
  │ openDatabase(path, version: 1, onCreate: _createTable)
  │ CREATE TABLE usuario (...)
  ▼
UsuarioRepositorio  ──> Database db = await DatabaseHelper().database
  │ db.insert('usuario', map)
  │ db.query('usuario')
  ▼
UsuarioModel  ──> fromJson(Map<String, dynamic>)
```

Responsabilidades:

| Capa | Archivo | Qué hace |
|---|---|---|
| Arranque | `lib/main.dart` | Inicializa bindings y **abre la BD antes de dibujar**. |
| Acceso a BD | `lib/database/database_helper.dart` | Singleton, ruta del fichero, apertura, DDL de creación. |
| Datos | `lib/repository/usuario_repositorio.dart` | Consultas `insert`/`query` con mapas. |
| Modelo | `lib/model/usuario_model.dart` | Representa un `usuario` y lo reconstruye desde un `Map`. |

No hay `bloc`, `provider`, `riverpod`, `get_it`, interfaces ni inyección de dependencias en esta capa.

---

## 4. Inicialización — `lib/main.dart` (código literal)

```dart
import 'package:clase/database/database_helper.dart';
import 'package:material_ui/material_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Text("<df"),
    );
  }
}
```

Puntos exactos:

1. `main` es **`async`** (a diferencia del raíz, que es síncrono).
2. `WidgetsFlutterBinding.ensureInitialized()` es obligatorio antes de tocar `sqflite`, porque el plugin usa canales de plataforma.
3. `await DatabaseHelper().database;` **pre-abre** la base de datos: `DatabaseHelper()` devuelve el singleton y el getter se encarga de crear el archivo y la tabla si no existen.
4. `const new({super.key});` es la forma explícita del constructor sin nombre de `MyApp` (el `new` es opcional en Dart; `const MyApp()` funciona igual). Es una escritura inusual del profesor, **no un error**.
5. `home: Text("<df")` es un marcador de depuración; no hay interfaz de usuario real todavía.

---

## 5. El corazón: `lib/database/database_helper.dart` (código literal)

```dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  factory DatabaseHelper(){
    return instance;
  }

  Future<Database> get database async{
    if(_database != null){
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async{
    String path = join(await getDatabasesPath(), "usuarios.db" );

    return await openDatabase(path, version: 1, onCreate: _createTable);

  }

  Future<void> _createTable (Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuario (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre text not null,
      correo text not null,
      edad INTEGER NOT NULL
      )
    ''');
  }
}
```

### 5.1 Análisis del patrón (esto es lo que hay que replicar)

| Elemento | Forma usada | Por qué / qué hace |
|---|---|---|
| Singleton | `static final DatabaseHelper instance = DatabaseHelper._init();` + constructor privado `DatabaseHelper._init();` + `factory DatabaseHelper() => instance;` | Una sola instancia en toda la app; cualquier archivo puede pedir `DatabaseHelper()` sin pasar referencias. |
| Cache de la BD | `static Database? _database;` | Evita abrir la BD en cada operación. |
| Getter lazy | `Future<Database> get database async` con `if (_database != null) return _database!;` | La primera llamada abre; las siguientes devuelven la instancia en cache. |
| Ruta | `join(await getDatabasesPath(), "usuarios.db")` de `package:path/path.dart` | `getDatabasesPath()` da el directorio privado de la app; `join` arma la ruta del fichero SQLite. |
| Apertura | `openDatabase(path, version: 1, onCreate: _createTable)` | `version: 1` inicial; `onCreate` solo se ejecuta la primera vez. |
| DDL | `db.execute(''' CREATE TABLE ... ''')` con SQL en triple comilla | Tabla `usuario`, columnas `id`, `nombre`, `correo`, `edad`. |
| Tipos SQL | `INTEGER PRIMARY KEY AUTOINCREMENT`, `text not null`, `INTEGER NOT NULL` | Mezcla intencional de mayúsculas/minúsculas en el SQL original; mantener si se copia literal. |
| Tipos Dart del import | `package:sqflite/sqflite.dart` para funciones + `package:sqflite/sqlite_api.dart` para el tipo `Database` | Ambos imports aparecen juntos en el archivo. |
| Manejo de errores | **Ninguno** (sin `try/catch`, sin `onUpgrade`) | Fiel al profesor: asume que la apertura funciona. |

### 5.2 Esquema resultante

| Columna | Tipo SQLite | Restricción |
|---|---|---|
| `id` | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` |
| `nombre` | `text` | `not null` |
| `correo` | `text` | `not null` |
| `edad` | `INTEGER` | `NOT NULL` |

Nombre del archivo: **`usuarios.db`** (plural), nombre de la tabla: **`usuario`** (singular). Esa diferencia es del original.

---

## 6. Modelo — `lib/model/usuario_model.dart` (código literal)

```dart
class UsuarioModel {
  int? id;
  String nombre;
  String correo;
  String edad;

  UsuarioModel({
    this.id,
    required this.nombre,
    required this.correo,
    required this.edad,
  });

  factory UsuarioModel.fromJson (Map<String, dynamic> json) {
    return UsuarioModel(
      id: json["id"],
      nombre: json["nombre"],
      correo: json["correo"],
      edad: json["edad"],
    );
  }
}
```

Convenciones del profesor aquí:

- Campos **mutables** (sin `final`), `id` nullable porque lo asigna SQLite.
- Constructor **no const**, con `required` para los tres campos obligatorios.
- `fromJson(Map<String, dynamic>)` con **acceso directo por clave y comillas dobles**: `json["id"]`, sin validación ni valores por defecto (a diferencia del proyecto raíz, que usa helpers `_asString`/`_asInt`).
- **No existe `toJson`**: el repositorio construye el mapa a mano.
- ⚠ `edad` es `String` en Dart pero `INTEGER` en SQLite. El profesor pasa el valor directamente a `db.insert`; SQLite intentará convertirlo. Al replicar, decide si mantienes el `String` (fidelidad) o lo cambias a `int` (corrección). Documentar la decisión.

---

## 7. Repositorio — `lib/repository/usuario_repositorio.dart` (código literal)

```dart
import 'package:clase/database/database_helper.dart';
import 'package:clase/model/usuario_model.dart';
import 'package:sqflite/sqflite.dart';

class UsuarioRepositorio {
  Future<int> insertUser(UsuarioModel user) async{
    Database db = await DatabaseHelper().database;
    return await db.insert('usuario', {
      "nombre": user.nombre,
      "correo": user.correo,
      "edad": user.edad
    });
  }

  Future<void> getUser () async {
    Database db = await DatabaseHelper().database;
    List<Map<String, dynamic>> data = await db.query("usuario");
  }

}
```

### 7.1 Qué hace

- `insertUser(UsuarioModel)` → `db.insert('usuario', {...})` y devuelve el `int` con el `rowid`/id insertado. **No incluye `id` en el mapa** (autoincremental).
- `getUser()` → `db.query("usuario")` guarda el resultado en `List<Map<String, dynamic>> data`.
- En ambos métodos se obtiene la BD **dentro del método** con `await DatabaseHelper().database`; no hay campo `db` en la clase ni constructor.

### 7.2 Lagunas reales del código del profesor (no ocultar)

- `getUser()` declara `Future<void>` y **descarta el resultado**: `data` queda sin usar (warning del analizador). Un `SELECT` correcto debería devolver `List<UsuarioModel>` o `List<Map<String, dynamic>>`.
- No hay `update`, `delete`, `getById`, `rawQuery` ni transacciones.
- No hay `try/catch` ni logs.
- El nombre de la clase lleva `Repositorio` (español), no `Repository`.
- `insert` usa comillas dobles en las claves del mapa; la tabla `'usuario'` va con comillas simples en `insert` y con dobles en `query`. Mezcla deliberada del original.

---

## 8. La forma de programar del profesor (resumen para una IA)

1. **Singleton manual**, sin paquetes: `static final instance`, constructor `_init()` privado, `factory () => instance`.
2. **Lazy initialization** con campo nullable estático y getter `async`.
3. **SQL crudo** en `db.execute(''' ... ''')`, sin migraciones ni `onUpgrade` en esta versión.
4. **Modelo Simple Old Dart**: campos públicos mutables, `factory fromJson` directo, sin `toJson`, sin const, sin null-safety defensiva.
5. **Repositorio delgado**: un método por operación, obtiene la BD en cada llamada, construye mapas literales, devuelve tipos de `sqflite`.
6. **Nombres en español**: `usuario`, `nombre`, `correo`, `edad`, `UsuarioModel`, `UsuarioRepositorio`, `insertUser` (método en inglés, clase en español).
7. **Comillas dobles** en las cadenas de datos y SQL del módulo de BD (el proyecto raíz usa mayoritariamente comillas simples).
8. **Sin control de errores** en la capa de datos.
9. **Inicialización explícita en `main`**, con `ensureInitialized()` y `await` antes de `runApp`.
10. **Carpetas `handler/` y `presentation/`** preparadas (vacías) para la futura capa de control/UI, pero hoy no hay patrón de UI del profesor que copiar; para la UI, reutiliza el estilo del proyecto raíz (§14).

---

## 9. Integración nativa del plugin `sqflite`

`clase/.flutter-plugins-dependencies` y los archivos generados muestran:

- Android: `sqflite_android` registrado en `android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java` (`com.tekartik.sqflite.SqflitePlugin`).
- iOS: `sqflite_darwin` en `ios/Runner/GeneratedPluginRegistrant.m`.
- macOS: `sqflite_darwin` en `macos/Flutter/GeneratedPluginRegistrant.swift`.
- **Linux, Windows y Web: sin plugin** → `sqflite` no funciona en esas plataformas con esta configuración.

Consecuencia al portar al raíz: basta con añadir `sqflite` y `path` al `pubspec.yaml` y ejecutar `flutter pub get`; Flutter regenera los `GeneratedPluginRegistrant` y el código Dart es idéntico. Probar la BD en **Android/iOS/macOS**, no en web ni escritorio Linux/Windows.

Ruta típica del fichero (Android): `/data/data/<package>/databases/usuarios.db`.

---

## 10. Estado real/verificado del proyecto `clase`

- `flutter analyze` **desde la raíz** incluye `clase/` y reporta 43 issues (el analizador raíz no lo excluye). `flutter analyze lib` en la raíz da "No issues found".
- En `clase/`, `.dart_tool/package_config.json` referencia rutas de la máquina `SCIS2PC18`; sin `flutter pub get` local, el analizador marca como no encontrados `package:sqflite/sqflite.dart`, `package:path/path.dart`, `package:material_ui/material_ui.dart` y `package:flutter_test/flutter_test.dart`, además de `Database`, `WidgetsFlutterBinding`, `runApp`, `BuildContext`, etc. **Son errores de dependencias no resueltas, no errores de lógica del código del profesor.**
- Warning real del código: `unused_local_variable` en `usuario_repositorio.dart:17` (`data` no se usa).
- `test/widget_test.dart` es el **test por defecto del contador**: espera `find.text('0')`, un botón `Icons.add` y `const MyApp()`. No corresponde a la app (`home: Text("<df")`) y fallaría aunque las dependencias estuvieran bien. **No usarlo como referencia de estilo.**
- No hay commits/git en esta carpeta; tratar los archivos como código del profesor a conservar.

---

## 11. Cómo trasladar este patrón al proyecto raíz (paso a paso)

Escenario objetivo: aplicar "la forma en que se conecta a la BD y se suben/extraen datos" del profesor al proyecto `cuenta`, manteniendo la app raíz funcionando.

### Paso 1 — Dependencias (`pubspec.yaml` de la raíz)

```yaml
dependencies:
  # ... las existentes ...
  path: ^1.9.1
  sqflite: ^2.4.6
```

Luego `flutter pub get`. (El raíz ya tiene `sdk: ^3.9.2`; compatible con este código.)

### Paso 2 — Crear `lib/database/database_helper.dart` en la raíz

Copiar el archivo del profesor **casi literal**, cambiando solo los imports a package absolutos (ya funciona tal cual porque usa `package:path` / `package:sqflite`, no relativos). Si se quiere otra tabla, cambiar `usuarios.db` / `CREATE TABLE usuario` / columnas, manteniendo la misma estructura de singleton y getter.

### Paso 3 — Crear el modelo

Copiar `clase/lib/model/usuario_model.dart` a `lib/model/usuario_model.dart` (nombre distinto de `lib/model/admin/` e `lib/model/auth/`, sin colisión). Adaptar al estilo raíz si se desea: `final`, constructor `const`, helpers `_asString`/`_asInt` — pero **eso ya no sería 100 % la forma del profesor**; decidir y documentar.

### Paso 4 — Crear el repositorio

Copiar `clase/lib/repository/usuario_repositorio.dart` a `lib/repository/usuario_repositorio.dart`. Corregir `getUser()` para que devuelva datos (el profesor lo dejó incompleto):

```dart
Future<List<UsuarioModel>> getUsers() async {
  Database db = await DatabaseHelper().database;
  List<Map<String, dynamic>> data = await db.query("usuario");
  return data.map(UsuarioModel.fromJson).toList();
}
```

### Paso 5 — Inicializar en `main.dart` sin romper Riverpod/GoRouter

El raíz tiene `void main()` síncrono y `runApp(const ProviderScope(child: MainApp()))`. La versión integrada:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();   // ya estaba

  await DatabaseHelper().database;             // NUEVO: abre/crea la BD

  GoRouter.optionURLReflectsImperativeAPIs = true;
  runApp(const ProviderScope(child: MainApp()));
}
```

Import a añadir: `import 'package:cuenta/database/database_helper.dart';`.

### Paso 6 — Consumirlo desde la UI

El profesor no dejó UI; usar el patrón de pantallas del raíz (§9 de `DOCUMENTACION-EXAMEN.md`): `StatefulWidget` con `loading/error/data`, `initState` → `await UsuarioRepositorio().getUsers()`, `if (!mounted) return;`, `setState`, `Skeletonizer` y `ErrorRetryWidget`. Si se requiere un `handler/`, crear `lib/handler/` siguiendo la intención del profesor, pero sin inventar una API desconocida.

### Paso 7 — Verificación

```powershell
flutter pub get
flutter analyze lib
flutter run      # Android/iOS/macOS
```

---

## 12. Plantillas listas para copiar (estilo del profesor)

### 12.1 Helper para otra entidad (mismo esquema)

```dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  factory DatabaseHelper(){
    return instance;
  }

  Future<Database> get database async{
    if(_database != null){
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async{
    String path = join(await getDatabasesPath(), "usuarios.db" );
    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  Future<void> _createTable (Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuario (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nombre text not null,
      correo text not null,
      edad INTEGER NOT NULL
      )
    ''');
  }
}
```

### 12.2 Repositorio con CRUD completo (extensión natural del original)

```dart
class UsuarioRepositorio {
  Future<int> insertUser(UsuarioModel user) async{
    Database db = await DatabaseHelper().database;
    return await db.insert('usuario', {
      "nombre": user.nombre,
      "correo": user.correo,
      "edad": user.edad
    });
  }

  Future<List<UsuarioModel>> getUser () async {
    Database db = await DatabaseHelper().database;
    List<Map<String, dynamic>> data = await db.query("usuario");
    return data.map(UsuarioModel.fromJson).toList();
  }

  Future<int> updateUser(UsuarioModel user) async{
    Database db = await DatabaseHelper().database;
    return await db.update('usuario', {
      "nombre": user.nombre,
      "correo": user.correo,
      "edad": user.edad
    }, where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> deleteUser(int id) async{
    Database db = await DatabaseHelper().database;
    return await db.delete('usuario', where: 'id = ?', whereArgs: [id]);
  }
}
```

### 12.3 Cambio de esquema (si se sube de versión)

El original no lo tiene; añadirlo **en el mismo estilo** cuando haga falta:

```dart
return await openDatabase(
  path,
  version: 2,
  onCreate: _createTable,
  onUpgrade: (Database db, int oldVersion, int newVersion) async {
    await db.execute('ALTER TABLE usuario ADD COLUMN activo INTEGER NOT NULL DEFAULT 1');
  },
);
```

---

## 13. Checklist para una IA que vaya a replicar este patrón

- [ ] `sqflite` y `path` en `pubspec.yaml` + `flutter pub get`.
- [ ] `lib/database/database_helper.dart` con singleton, `_database` cache, `getDatabasesPath()`, `join()`, `openDatabase(version: 1, onCreate: ...)`.
- [ ] SQL `CREATE TABLE` en triple comilla con `id INTEGER PRIMARY KEY AUTOINCREMENT`.
- [ ] Modelo con campos públicos y `factory fromJson(Map<String, dynamic>)`.
- [ ] Repositorio con `Database db = await DatabaseHelper().database;` **dentro** de cada método.
- [ ] `insert` sin `id` en el mapa; `query` mapeado a modelos (corregir el `void` del profesor).
- [ ] `main()` `async` con `WidgetsFlutterBinding.ensureInitialized()` y `await DatabaseHelper().database` antes de `runApp`.
- [ ] En la raíz, conservar `ProviderScope`, `GoRouter.optionURLReflectsImperativeAPIs` y `MaterialApp.router`.
- [ ] Usar imports `package:cuenta/...` en la raíz y `package:clase/...` en `clase/`.
- [ ] No usar web/Linux/Windows para probar SQLite con esta configuración.
- [ ] `flutter analyze lib` en la raíz sin errores nuevos.

---

## 14. Diferencias entre ambos proyectos y reglas de decisión

| Aspecto | Proyecto raíz `cuenta` | Proyecto `clase` (profesor) | Regla al integrar |
|---|---|---|---|
| Paquete Dart | `package:cuenta/...` | `package:clase/...` | Usar `package:cuenta/...` en la raíz. |
| SDK | `^3.9.2` | `^3.14.0` | El código del profesor compila en el raíz; no asumir APIs nuevas del raíz en `clase`. |
| HTTP/BD | Dio + APIs REST | sqflite local | Mantener ambos: REST para pantallas actuales, SQLite para lo nuevo. |
| Estado | Riverpod (tema) + `setState` | Ninguno | Para la UI nueva, copiar el `setState` del raíz. |
| Estilo de cadenas | Mayoría comillas simples | Comillas dobles en BD/modelo/repo | En la raíz, preferir comillas simples (convención raíz); conservar dobles si se copia literal. |
| Modelos | `final`, `const`, `_asString`/`_asInt` | mutables, sin const, `json["x"]` directo | Elegir una convención y ser consistente; si el objetivo es "replicar al profesor", usar la suya. |
| Capas | `services` (sin repository) | `database` + `model` + `repository` (+ `handler`/`presentation` vacías) | Añadir `database/` y `repository/` al raíz sin eliminar `services/`. |
| Errores | `ApiException` con mensajes en español | Sin manejo | En la raíz, envolver errores de BD en `ApiException` para no romper `ErrorRetryWidget`. |
| Arranque | `void main()` síncrono | `void main() async` | Hacer `async` el `main` del raíz (paso 5). |
| Pruebas | Sin `test/` | Test de plantilla roto | No copiar el test del profesor. |

**Resumen en una frase para una IA:** *para añadir persistencia al proyecto raíz, copia la estructura `database_helper.dart` (singleton + getter lazy + SQLite) y `usuario_repositorio.dart` (insert/query con mapas) del profesor, añade `sqflite` y `path`, abre la BD en un `main() async` con `ensureInitialized()` antes del `ProviderScope`, y construye la UI con el patrón `StatefulWidget` + `Skeletonizer` + `ErrorRetryWidget` ya existente en el raíz.*

---

## 15. Índice rápido archivo → responsabilidad

| Archivo | Responsabilidad |
|---|---|
| `clase/pubspec.yaml` | Declara `sqflite ^2.4.6` y `path ^1.9.1` |
| `clase/lib/main.dart` | `ensureInitialized()`, `await DatabaseHelper().database`, `runApp` |
| `clase/lib/database/database_helper.dart` | Singleton, ruta `usuarios.db`, `openDatabase(version: 1)`, `CREATE TABLE usuario` |
| `clase/lib/model/usuario_model.dart` | `UsuarioModel` + `fromJson` directo |
| `clase/lib/repository/usuario_repositorio.dart` | `insertUser()` (INSERT) y `getUser()` (SELECT incompleto) |
| `clase/lib/handler/` | Vacío (intención de capa de control) |
| `clase/lib/presentation/` | Vacía (intención de capa de UI) |
| `clase/test/widget_test.dart` | Plantilla del contador, no representativa |
| `clase/.flutter-plugins-dependencies` | Registro de `sqflite_android` / `sqflite_darwin` |
