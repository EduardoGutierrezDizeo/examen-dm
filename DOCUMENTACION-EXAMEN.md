# Documentación técnica — Proyecto raíz `cuenta` (Examen)

> **Estado del documento:** 25 de noviembre de 2026.
> **Alcance:** todo el proyecto raíz (`C:\Users\tutov\Desktop\Examen`) **excluyendo deliberadamente la carpeta `clase/`**. Esa carpeta es un proyecto Flutter distinto y se documenta por separado en `DOCUMENTACION-DB.md`.
> **Audiencia:** una IA o desarrollador que deba entender, mantener y **replicar exactamente la forma de programar** de este proyecto para añadir pantallas, endpoints, widgets o flips de datos.
> **Fuente:** código real leído archivo por archivo. No es una descripción genérica de Flutter.

---

## 0. Cómo usar esta documentación

1. Lee las secciones **1–3** para entender el stack, la estructura y el arranque.
2. Lee **4–10** para copiar los patrones (tema, rutas, auth, servicios, modelos, pantallas, widgets).
3. Usa **11–12** como **reglas y plantillas obligatorias** cuando escribas código nuevo.
4. Consulta **13–14** antes de dar por terminado un cambio (estado real del analizador y deudas conocidas).
5. **Regla de oro:** cuando haya duda entre "hacerlo bien en Flutter genérico" y "hacerlo como está hecho aquí", hazlo como está hecho aquí, salvo que se indique lo contrario en la sección 14.

---

## 1. Identidad, dominio y stack

### 1.1 Identidad

| Dato | Valor |
|---|---|
| `name` en `pubspec.yaml` | `cuenta` |
| `version` | `0.1.0` (sin `+build`) |
| `publish_to` | `'none'` |
| SDK | `^3.9.2` (Dart 3.9+) |
| Tipo de proyecto | `project_type: app` (`.metadata`) |
| Idioma de la UI | Español (`Locale('es')`, sin internacionalización de textos: los strings están en español directamente) |
| Plataformas generadas | `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/` (código de plataforma estándar, no se edita a mano) |
| Pruebas | **No existe carpeta `test/` en el proyecto raíz** |

### 1.2 Dominio de la aplicación

Aplicación académica de administración donde **los "productos" son personajes de Dragon Ball**.

- Login contra **Fake Store API**.
- Perfil del usuario autenticado contra **Fake Store API**.
- Listado y detalle de personajes contra **DBZ API**, bajo el prefijo de rutas `/admin/*`.
- Tema claro/oscuro persistido localmente.
- **No hay creación de productos**: el `POST /api/characters` de DBZ API exige un JWT propio de DBZ y responde `401`. El `README.md` lo documenta; por eso no existe formulario de alta.

### 1.3 Dependencias exactas (`pubspec.yaml`)

```yaml
dependencies:
  dio: ^5.9.0                      # HTTP
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_riverpod: ^3.3.1         # solo tema (StateNotifierProvider)
  flutter_secure_storage: ^9.2.4   # token JWT
  go_router: ^16.3.0               # rutas + redirect + ShellRoute
  shared_preferences: ^2.5.5       # flag de tema
  skeletonizer: ^2.1.1             # shimmer de carga

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

`flutter: uses-material-design: true`. **No hay `assets` ni fuentes personalizadas declaradas.**

### 1.4 Comandos

```powershell
flutter pub get
flutter analyze lib        # IMPORTANTE: ver §13, analizar solo lib evita arrastrar `clase/`
flutter run
```

Configuraciones VS Code en `.vscode/launch.json`: `cuenta`, `cuenta (profile mode)`, `cuenta (release mode)` y `cuenta (debug mode) emulators` (con `emulatorId: Medium_Phone_API_36.1`).

---

## 2. Estructura de carpetas

Árbol completo de las fuentes que forman la app (se omiten los directorios nativos generados):

```
Examen/                              ← raíz del proyecto "cuenta"
├─ pubspec.yaml                      dependencias y metadata
├─ pubspec.lock
├─ analysis_options.yaml             include flutter_lints; exclude build/android/ios/web/windows/macos/linux
├─ README.md                         APIs usadas + limitación del POST de DBZ
├─ .metadata / devtools_options.yaml
├─ .vscode/launch.json               configuraciones de ejecución
├─ android/ ios/ web/ linux/ macos/ windows/     (generado por Flutter)
├─ clase/                            ← OTRO proyecto Flutter; NO parte de esta app (ver DOCUMENTACION-DB.md)
└─ lib/
   ├─ main.dart                      entrada: ProviderScope + MaterialApp.router
   ├─ config/
   │  ├─ router/
   │  │  ├─ router_config.dart       GoRouter global, redirect por token, ShellRoute
   │  │  ├─ router_admin.dart        catálogo declarativo de rutas admin
   │  │  └─ router_model.dart        clase de descriptor de ruta (RouterModel)
   │  └─ theme/
   │     └─ app_theme.dart           ThemeData Material 3 a partir de colorSchemeSeed
   ├─ helpers/
   │  ├─ api_exception.dart          excepción de dominio + traducción de DioException
   │  ├─ interceptor.dart            AuthInterceptor: cabecera Bearer + logout en 401
   │  ├─ jwt_helper.dart             userIdFromToken: decodifica `sub` del JWT
   │  ├─ network_config.dart         timeouts centralizados
   │  └─ token.dart                  AuthNotifier (ChangeNotifier) — legacy, NO usado
   ├─ model/
   │  ├─ admin/
   │  │  ├─ character_model.dart     CharacterModel + CharacterTransformation
   │  │  └─ profile_model.dart       ProfileModel (perfil de Fake Store)
   │  └─ auth/
   │     └─ auth_model.dart          AuthModel (token del login)
   ├─ presentation/
   │  ├─ admin/
   │  │  ├─ screen_admin.dart        barril de exports (PersonajesScreen, PagoScreen)
   │  │  ├─ layout/
   │  │  │  ├─ layout.dart           Scaffold con AppBar + Drawer + child
   │  │  │  └─ drawer_widget.dart    menú desde routerConfigAdmin + logout
   │  │  ├─ pago/
   │  │  │  └─ pago_screen.dart      Placeholder (ruta no registrada aún)
   │  │  ├─ personajes/
   │  │  │  ├─ personajes_screen.dart  envoltorio SafeArea -> ConsultScreen
   │  │  │  ├─ consult_screen.dart     listado, Skeletons, ImageCustom local
   │  │  │  └─ detail_screen.dart      detalle con ImageSlider + chips
   │  │  └─ profile/
   │  │     └─ profile_screen.dart     perfil en tarjeta con _item()
   │  ├─ public/
   │  │  └─ auth/
   │  │     └─ auth_screen.dart       login (ConsumerStatefulWidget)
   │  └─ shared/
   │     ├─ error_retry_widget.dart   ErrorRetryWidget
   │     └─ images/
   │        └─ images_widget.dart     SliderImage + ImageSlider + _SliderPicture
   ├─ providers/
   │  └─ theme_provider.dart         ThemeNotifier (Riverpod) + SharedPreferences
   └─ services/
      ├─ admin/
      │  ├─ personajes/personajes_service.dart
      │  └─ profile/profile_service.dart
      └─ auth/auth_service.dart
```

### 2.1 Capas y dirección de dependencias

```
main.dart  ──> config/router ──> presentation/*
                 │                   │
                 │                   ├──> services/* ──> helpers/* + model/*
                 │                   └──> model/*, presentation/shared/*
                 └──> providers/theme_provider.dart
                 └──> config/theme/app_theme.dart
```

- **Presentation** llama directamente a **services** (no existe capa `repository` en este proyecto raíz).
- **Services** usan **Dio**, traducen errores a `ApiException` y devuelven **modelos**.
- **Helpers** son utilitarios sin estado de UI (salvo `AuthNotifier`, que está muerto).
- **Config** concentra enrutado y tema.
- **Providers** solo gestiona el tema; el resto del estado es local de `StatefulWidget`.

---

## 3. Arranque de la aplicación (`lib/main.dart`)

Código literal y su explicación:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  GoRouter.optionURLReflectsImperativeAPIs = true;

  runApp(const ProviderScope(child: MainApp()));
}
```

1. `WidgetsFlutterBinding.ensureInitialized()` se llama **antes de `runApp`** porque el router y el storage son plugins.
2. `GoRouter.optionURLReflectsImperativeAPIs = true` se activa globalmente (necesario para que la URL siga a `context.go/push`).
3. Toda la app se envuelve en `const ProviderScope(child: MainApp())`; sin este `ProviderScope`, `ref.watch(themeProvider)` fallaría.

```dart
class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return MaterialApp.router(
      routerConfig: appRouter,
      themeMode: theme ? ThemeMode.dark : ThemeMode.light,
      locale: const Locale('es'),
      theme: AppTheme().themeData(false),
      darkTheme: AppTheme().themeData(true),
      debugShowCheckedModeBanner: false,
      supportedLocales: const [Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
```

- `MainApp` es **`ConsumerWidget`**, no `StatelessWidget`: es el único punto donde se observa el proveedor de tema global.
- Se usan **dos instancias** de `AppTheme()`, una por cada `ThemeData` (claro y oscuro), ambas con `selectedColor = 0`.
- `locale` fijo español + delegados de `flutter_localizations` para que los widgets Material (date pickers, etc.) hablen español.

---

## 4. Tema y preferencias

### 4.1 `lib/config/theme/app_theme.dart`

```dart
const Color _dragonOrange = Color(0xffe65100);

const List<Color> _colorThemes = [
  _dragonOrange, Colors.blue, Colors.red, Colors.yellow, Colors.lightGreen,
];

class AppTheme {
  final int selectedColor;

  AppTheme({this.selectedColor = 0})
    : assert(selectedColor >= 0 && selectedColor < _colorThemes.length,
          'Color > 0  and < ${_colorThemes.length}');

  Color get colorTheme => _colorThemes[selectedColor];

  ThemeData themeData(bool brightness) {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _colorThemes[selectedColor],
      appBarTheme: AppBarTheme(
        backgroundColor: _colorThemes[selectedColor],
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        centerTitle: false,
      ),
      brightness: brightness ? Brightness.dark : Brightness.light,
    );
  }
}
```

Patrones a replicar: constantes privadas con `_`, paleta como `const List<Color>`, validación con `assert`, **un solo `themeData(bool)`** que recibe el brillo en vez de dos métodos, `useMaterial3: true`, `colorSchemeSeed`, `appBarTheme` con color de marca.

### 4.2 `lib/providers/theme_provider.dart`

```dart
import 'package:flutter_riverpod/legacy.dart';   // Riverpod 3: StateNotifier va en /legacy.dart
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false) {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isDarkMode') ?? false;
  }

  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = !state;
    await prefs.setBool('isDarkMode', state);
  }
}
```

- Estado: un simple `bool` (`false` = claro).
- Clave de persistencia: **`isDarkMode`** en `SharedPreferences`.
- Se consume en dos sitios: `ref.watch(themeProvider)` en `MainApp` y en `AuthScreen`; se escribe en `ref.read(themeProvider.notifier).toggleTheme()` desde el `IconButton` del login.
- **No hay toggle de tema dentro del área admin** (solo en la pantalla de login).

---

## 5. Navegación (`go_router`)

### 5.1 Descriptor declarativo de rutas — `router_model.dart`

```dart
class RouterModel {
  String name;
  GoRouterWidgetBuilder screen;
  String title;
  String patch;          // ojo: nombre del campo en el código original (no "path")
  IconData icon;
  String description;
  bool inDrawer;         // por defecto true

  RouterModel({
    required this.name,
    required this.screen,
    required this.title,
    required this.patch,
    required this.icon,
    required this.description,
    this.inDrawer = true,
  });
}
```

Es un DTO de configuración: guarda el builder de la pantalla, no un widget ya instanciado. `screen` es de tipo `GoRouterWidgetBuilder`, por eso se firma como `(context, state) => ...`.

### 5.2 Catálogo admin — `router_admin.dart`

```dart
final routerConfigAdmin = <RouterModel>[
  RouterModel(
    name: 'Personajes',
    screen: (context, state) => const PersonajesScreen(),
    title: 'Personajes',
    patch: '/admin/personajes',
    icon: Icons.shelves,
    description: '',
  ),
  RouterModel(
    name: 'Detalle del personaje',
    screen: (context, state) =>
        DetailScreen(id: state.pathParameters['id'] ?? ''),
    title: 'Personaje',
    patch: '/admin/personajes/:id',
    icon: Icons.shelves,
    description: '',
    inDrawer: false,
  ),
  RouterModel(
    name: 'Perfil',
    screen: (context, state) => ProfileScreen(),
    title: 'Perfil',
    patch: '/admin/profile',
    icon: Icons.person,
    description: '',
  ),
];
```

Convenciones observables:

- Las rutas se **declaran en una lista**, y `GoRouter` se construye mapeándola (no se escriben `GoRoute` a mano una por una).
- El título del `AppBar` del Shell sale de `name`/`topRoute?.name`, mientras que `title` y `description` se rellenan pero **no se consumen** en la UI actual.
- La ruta de detalle oculta del drawer con `inDrawer: false` y toma el id con `state.pathParameters['id'] ?? ''`.
- Mezcla intencional: `const PersonajesScreen()` pero `ProfileScreen()` sin `const` (porque `ProfileModel`/servicio no son const). Mantener esa distinción al replicar.

### 5.3 Router global y guardia de sesión — `router_config.dart`

```dart
final storage = FlutterSecureStorage();     // instancia global, exports implícito

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final token = await storage.read(key: 'token');

    final isLoginRoute = state.matchedLocation == '/';
    final isAuthenticated = token != null && token.isNotEmpty;

    if (!isAuthenticated) {
      return isLoginRoute ? null : '/';
    }
    if (isLoginRoute) {
      return '/admin/personajes';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/', name: 'login', builder: (context, state) => const AuthScreen()),
    ShellRoute(
      builder: (context, state, child) {
        return Layout(
          title: state.topRoute?.name ?? 'Administrador',
          child: child,
        );
      },
      routes: [
        ...routerConfigAdmin.map((screen) {
          return GoRoute(
            path: screen.patch,
            builder: screen.screen,
            name: screen.name,
          );
        }),
      ],
    ),
  ],
);
```

Reglas de navegación:

| Situación | Acción |
|---|---|
| Sin token, ruta cualquiera que no sea `/` | `redirect` a `/` |
| Sin token en `/` | permite (`return null`) |
| Con token en `/` | `redirect` a `/admin/personajes` |
| Login correcto | `context.goNamed('Personajes')` |
| Item del drawer | `context.go(res.patch)` tras `Navigator.pop(context)` |
| Listado → detalle | `context.push('/admin/personajes/$id')` (push conserva el listado en la pila) |
| Cerrar sesión | borrar `token` + `context.go('/')` |
| 401 en una petición | `AuthInterceptor` borra token y `appRouter.go('/')` |

- `ShellRoute` envuelve **todas** las rutas admin con `Layout` (AppBar + Drawer). Por eso las pantallas hijas crean su propio `Scaffold(body: ...)` sin AppBar: el AppBar lo pone el shell.
- `initialLocation: '/'`.
- El `redirect` es `async` y consulta el storage en cada navegación: es la única "fuente de verdad" de la sesión, junto con el interceptor.

---

## 6. Autenticación y almacenamiento seguro

### 6.1 Flujo completo

```
AuthScreen (form)
  └─ AuthService.login(username, password)
       ├─ Dio POST /auth/login -> { token: "..." }
       ├─ AuthModel.fromJson -> token
       └─ FlutterSecureStorage.write(key: 'token')
            └─ context.goNamed('Personajes')
                 └─ GoRouter.redirect lee token -> permite /admin/*
                      └─ AuthInterceptor añade "Authorization: Bearer <token>"
```

### 6.2 `lib/services/auth/auth_service.dart`

```dart
class AuthService {
  static final _dio = Dio(
    BaseOptions(
      connectTimeout: NetworkConfig.connectTimeout,
      sendTimeout: NetworkConfig.sendTimeout,
      receiveTimeout: NetworkConfig.receiveTimeout,
    ),
  );
  static final _storage = FlutterSecureStorage();
  static final url = 'https://fakestoreapi.com';

  static Future<void> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '$url/auth/login',
        data: {'username': username, 'password': password},
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ApiException('Respuesta de login inválida');
      }

      final res = AuthModel.fromJson(data);
      await _storage.write(key: 'token', value: res.token);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const ApiException('Usuario o contraseña incorrectos');
      }
      throw ApiException.fromDio(e);
    }
  }
}
```

Detalles a copiar:

- **Dio estático por servicio**, creado con `BaseOptions` y timeouts importados de `NetworkConfig`.
- **Sin `baseUrl` en `BaseOptions`**: se usa `static final url` y se interpola en cada llamada (`'$url/auth/login'`).
- El servicio **no navega** y **no guarda estado de UI**: solo lanza excepciones o completa.
- El `401` de login tiene mensaje propio; otros errores pasan por `ApiException.fromDio`.

### 6.3 `lib/model/auth/auth_model.dart`

```dart
class AuthModel {
  final String token;
  const AuthModel({required this.token});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    if (token is! String || token.isEmpty) {
      throw const ApiException('Respuesta de login inválida');
    }
    return AuthModel(token: token);
  }
}
```

### 6.4 `lib/helpers/interceptor.dart`

```dart
class AuthInterceptor extends Interceptor {
  static final _storage = FlutterSecureStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final String token = await _storage.read(key: 'token') ?? '';
    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isLoginRequest = err.requestOptions.path.contains('/auth/login');

    if (err.response?.statusCode == 401 && !isLoginRequest) {
      await _storage.delete(key: 'token');
      appRouter.go('/');
    }
    handler.next(err);
  }
}
```

- Se añade a **todos** los Dio de los servicios excepto `AuthService` (el login no lo necesita).
- Efecto colateral real: el token de Fake Store también se envía a DBZ API en las peticiones `GET`; como esos endpoints son públicos, no afecta. **No inventar un flujo de refresh de token**.
- El interceptor importa `appRouter` desde `config/router/router_config.dart` (acoplamiento directo helper → router).

### 6.5 `lib/helpers/jwt_helper.dart` y lectura del `sub`

```dart
int? userIdFromToken(String token) {
  try {
    final parts = token.split('.');
    if (parts.length < 2) return null;
    final normalized = base64Url.normalize(parts[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    final decoded = jsonDecode(payload);
    if (decoded is! Map) return null;
    final sub = decoded['sub'];
    if (sub is int) return sub;
    if (sub is String) return int.tryParse(sub);
    return null;
  } catch (_) {
    return null;
  }
}
```

No hay verificación de firma: solo se decodifica el payload para sacar `sub`. Es deliberado en este proyecto académico.

### 6.6 `lib/helpers/token.dart` — código presente pero **sin uso**

`AuthNotifier extends ChangeNotifier` con `loadToken()`, `login(String)`, `logout()` y `FlutterSecureStorage` propio. **No está registrado en ningún provider ni es referenciado por ningún widget.** No conectarlo "porque sí": la sesión real se maneja con `router_config.dart`, `AuthInterceptor` y borrado directo en `DrawerWidget`. Es deuda/legacy.

### 6.7 Cierre de sesión (`drawer_widget.dart`)

```dart
onTap: () async {
  Navigator.pop(context);
  const FlutterSecureStorage flutterSecureStorage = FlutterSecureStorage();
  await flutterSecureStorage.delete(key: 'token');
  if (!context.mounted) return;
  context.go('/');
},
```

---

## 7. API: endpoints, servicios y errores

### 7.1 Tabla de endpoints

| Método | URL | Servicio | Uso |
|---|---|---|---|
| `POST` | `https://fakestoreapi.com/auth/login` | `AuthService.login` | Body `{'username': ..., 'password': ...}` → `{token}` |
| `GET` | `https://fakestoreapi.com/users/{id}` | `ProfileService.getProfile` | Perfil; `id` viene del `sub` del JWT |
| `GET` | `https://dragonball-api.com/api/characters?page=N&limit=100` | `PersonajesService.getPersonajes` | Listado paginado; se recorren todas las páginas |
| `GET` | `https://dragonball-api.com/api/characters/{id}` | `PersonajesService.getDetail` | Detalle de un personaje |
| `POST` | `https://dragonball-api.com/api/characters` | **NO implementado** | Requiere JWT propio de DBZ; responde `401` (ver `README.md`) |

### 7.2 Forma de las respuestas que espera el código

```jsonc
// GET /characters -> Map con "items" y "meta"
{
  "items": [ { "id": 1, "name": "...", "ki": "...", "maxKi": "...", "race": "...",
               "gender": "...", "description": "...", "image": "...", "affiliation": "...",
               "originPlanet": { "name": "..." },
               "transformations": [ { "name": "...", "image": "..." } ] } ],
  "meta": { "totalPages": 3 }
}

// GET /users/{id} -> Map anidado
{
  "id": 1, "username": "...", "email": "...",
  "name": { "firstname": "...", "lastname": "..." },
  "phone": "...", "address": { "city": "..." }
}
```

### 7.3 `PersonajesService` — paginación y detalle

```dart
class PersonajesService {
  static final _dio = Dio(
    BaseOptions(
      connectTimeout: NetworkConfig.connectTimeout,
      sendTimeout: NetworkConfig.sendTimeout,
      receiveTimeout: NetworkConfig.receiveTimeout,
    ),
  )..interceptors.add(AuthInterceptor());
  static final url = 'https://dragonball-api.com/api';

  static Future<List<CharacterModel>> getPersonajes() async {
    try {
      const limit = 100;
      final characters = <CharacterModel>[];

      final firstResponse = await _dio.get(
        '$url/characters',
        queryParameters: {'page': 1, 'limit': limit},
      );

      final firstData = firstResponse.data;
      if (firstData is! Map || firstData['items'] is! List) {
        throw const ApiException('Respuesta inválida del servidor');
      }

      characters.addAll((firstData['items'] as List).map(CharacterModel.fromJson));

      final totalPages = _totalPages(firstData['meta']);
      for (var page = 2; page <= totalPages; page++) {
        final response = await _dio.get(
          '$url/characters',
          queryParameters: {'page': page, 'limit': limit},
        );
        final data = response.data;
        if (data is! Map || data['items'] is! List) {
          throw const ApiException('Respuesta inválida del servidor');
        }
        characters.addAll((data['items'] as List).map(CharacterModel.fromJson));
      }
      return characters;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
  // getDetail(...) y _totalPages(...) ver archivo
}
```

Patrones:

- `static Future<...>` para lista y detalle; `static final url`.
- `queryParameters` como mapa literal con claves `'page'` y `'limit'`.
- Validación de forma con `is! Map` / `is! List` lanzando `ApiException`, **antes** de mapear.
- Mapeo funcional: `(lista as List).map(Model.fromJson)` + `addAll`.
- `_totalPages(dynamic meta)` privado, tolerante con `int`, `num`, `String`, valor por defecto `1`.
- `getDetail`: `GET '$url/characters/$id'` y, si `400`/`404`, lanza `ApiException('Personaje no encontrado', statusCode: ...)`; el resto pasa por `fromDio`.

### 7.4 `ProfileService` — token → id → GET

```dart
Future<ProfileModel> getProfile() async {                 // ojo: método de instancia
  final token = await _storage.read(key: 'token') ?? '';
  final userId = userIdFromToken(token);

  if (userId == null) {
    throw const ApiException('Sesión inválida, vuelve a iniciar sesión.');
  }

  try {
    final response = await _dio.get('$url/users/$userId');
    return ProfileModel.fromJson(response.data);
  } on DioException catch (e) {
    throw ApiException.fromDio(e);
  }
}
```

Llamado como `ProfileService().getProfile()` en la pantalla. Es el único servicio con método no estático.

### 7.5 Timeouts — `network_config.dart`

```dart
class NetworkConfig {
  const NetworkConfig._();

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
```

Clase abstracta por convención (constructor privado `const`), solo constantes estáticas.

### 7.6 Traducción de errores — `api_exception.dart`

```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});

  factory ApiException.fromDio(DioException error) { ... }

  @override
  String toString() => message;
}
```

Reglas de mapeo (en este orden):

| Condición | Mensaje |
|---|---|
| `connectionError` o `error.error.runtimeType.toString() == 'SocketException'` | `Sin conexión a internet. Revisa tu red e inténtalo de nuevo.` |
| `connectionTimeout` / `sendTimeout` / `receiveTimeout` | `La conexión está lenta y la petición tardó demasiado. Inténtalo de nuevo.` |
| `badResponse` + `401` | `Tu sesión no es válida o expiró.` |
| `badResponse` + `404` | `No se encontró el recurso solicitado.` |
| `badResponse` + `400` | `Solicitud inválida.` |
| `badResponse` + `5xx` | `El servidor tuvo un problema. Inténtalo más tarde.` |
| otro `badResponse` | `Error inesperado (código N).` |
| `cancel` | `La petición fue cancelada.` |
| fallback | `Ocurrió un error inesperado.` |

Todos los mensajes de usuario están en español. Las pantallas muestran `e.message` directamente.

---

## 8. Modelos y parseo manual de JSON

No se usa `json_serializable`, `freezed` ni code generation. Todos los modelos tienen `factory fromJson` manual y **parseo defensivo**.

### 8.1 `CharacterModel` + `CharacterTransformation`

- Campos `final`: `id`, `name`, `ki`, `maxKi`, `race`, `gender`, `description`, `image`, `affiliation`, `originPlanetName`, `transformations`.
- Constructor `const` con todos los campos `required`.
- `factory CharacterModel.fromJson(dynamic json)`:
  - `final data = json is Map ? json : const <String, dynamic>{};`
  - **Aplana** `originPlanet.name` → `originPlanetName` (si `originPlanet` no es `Map`, `''`).
  - Transformaciones: `_asTransformations(data['transformations'])` → `map(CharacterTransformation.fromJson).toList()`.
- Helpers privados de archivo:

```dart
String _asString(dynamic value) => value is String ? value : '';

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

List<CharacterTransformation> _asTransformations(dynamic value) {
  if (value is! List) return const [];
  return value.map(CharacterTransformation.fromJson).toList();
}
```

Estos mismos helpers (copiados tal cual) aparecen en `profile_model.dart`. **Es la convención del proyecto**: nunca fallar por un campo ausente; degradar a `''`, `0` o `const []`.

### 8.2 `ProfileModel`

Campos: `id`, `username`, `email`, `fullName`, `phone`, `city`. `fromJson` compone `fullName` con `'$firstname $lastname'.trim()` y saca `city` de `address['city']`. Constructor **no const** (convivencia con `ProfileScreen()` sin const).

### 8.3 `AuthModel`

Único modelo que **sí lanza** `ApiException` cuando la forma del JSON es inválida.

### 8.4 Uso de modelos como "placeholder" de skeleton

Los propios modelos se usan para fabricar datos falsos de carga:

```dart
final placeholder = CharacterModel.fromJson(const {
  'name': 'Nombre del personaje',
  'race': 'Raza',
  'ki': 'Ki',
});
```

Esto evita duplicar constructores de relleno y es un patrón a mantener.

---

## 9. Patrón de pantallas con datos remotos

Tres pantallas (`ConsultScreen`, `DetailScreen`, `ProfileScreen`) repiten **exactamente** la misma máquina de estados local:

```dart
class XScreen extends StatefulWidget {
  const XScreen({super.key});
  @override
  State<XScreen> createState() => _XScreenState();
}

class _XScreenState extends State<XScreen> {
  bool loading = true;
  String? error;
  // Tipo? data;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response = await Service.getData();
      if (!mounted) return;                     // SEMPRE después del await
      setState(() {
        data = response;
        loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.message;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Ocurrió un error inesperado.';
        loading = false;
      });
    }
  }

  Widget _buildBody() {
    if (loading) {
      return Skeletonizer(
        enabled: true,
        enableSwitchAnimation: true,
        child: _content(_placeholder()),
      );
    }
    if (error != null) {
      return ErrorRetryWidget(message: error!, onRetry: getData);
    }
    if (data == null /* o lista vacía */) {
      return const Center(child: Text('No hay datos disponibles'));
    }
    return _content(data!);
  }
}
```

Puntos exactos:

1. `initState()` dispara la carga; **no** hay `FutureBuilder`, ni Riverpod para datos, ni `BLoC`.
2. Tres estados en variables de instancia: `loading`, `error`, dato.
3. `setState` antes de la petición y después; `if (!mounted) return;` tras **cada** `await`.
4. `on ApiException catch (e)` muestra `e.message`; `catch (_)` genérico con texto fijo.
5. `Skeletonizer` + un modelo placeholder (`List.filled(8, placeholder)` en el listado).
6. `ErrorRetryWidget(message: ..., onRetry: getData)` reutiliza la misma función de carga para reintentar.
7. Cada pantalla devuelve su propio `Scaffold(body: ...)`, porque el AppBar lo aporta `ShellRoute`.
8. Métodos privados de construcción: `_buildBody()`, `_content(...)`, `_placeholder()`, `_item(...)`, `_chip(...)`, `_characterTile(...)`.

### 9.1 Variante con formulario: `AuthScreen`

- `ConsumerStatefulWidget` + `ConsumerState` para poder `ref.watch(themeProvider)`.
- `GlobalKey<FormState>` + dos `TextEditingController` (username, password) con `dispose()`.
- `bool _loading` privado (prefijo `_`, a diferencia de las pantallas de datos).
- `TextFormField` con `OutlineInputBorder`, `prefixIcon`, `validator` que solo valida vacío; password con `obscureText: true`.
- `FilledButton.icon` con `onPressed: _loading ? null : _login` y `CircularProgressIndicator(strokeWidth: 2)` como icono mientras carga.
- Errores con `ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)))`; `finally` para restaurar `_loading` con `if (mounted)`.
- Layout: `Scaffold > SafeArea > Stack > Center(SingleChildScrollView > ConstrainedBox(maxWidth: 400) > Form > Column)` y un `Positioned(top: 8, right: 8, child: IconButton(...))` para el tema.

---

## 10. Catálogo de widgets propios y cómo están construidos

### 10.1 `Layout` (`presentation/admin/layout/layout.dart`)

`StatelessWidget` con `child` y `title` requeridos:

```dart
Scaffold(
  appBar: AppBar(title: Text(title)),
  drawer: DrawerWidget(),
  body: child,
)
```

Es el "shell" de `ShellRoute`.

### 10.2 `DrawerWidget`

- `StatelessWidget` const.
- Calcula `drawerRoutes = routerConfigAdmin.where((res) => res.inDrawer).toList()` — **el menú se deriva del router**, no se escribe a mano. (Luego vuelve a aplicar `.where` dentro del `map`, redundancia presente en el código.)
- Obtiene la ruta activa con `GoRouter.of(context).routerDelegate.currentConfiguration.last.matchedLocation`.
- Cabecera: `Container` con `colorScheme.surfaceContainerHighest`, padding que incluye `MediaQuery.of(context).padding.top`, dos `_member(...)` con datos **hardcodeados** (códigos `0192127`, `0212278`) y un `Divider`.
- `_member(BuildContext context, {required String code, name, email})` privado: `Row > CircleAvatar(radius: 22, child: Text(name.substring(0,1))) + SizedBox(12) + Expanded(Column(...))`, estilos desde `Theme.of(context)`.
- Items: `ListTile(selected: isSelected, selectedTileColor: Colors.grey[300], leading: Icon(res.icon), title: Text(res.name))`; `Navigator.pop` y `context.go(res.patch)` si no está seleccionado.
- `Spacer()` y al final el `ListTile` de "Cerrar Sesión" (§6.7).

### 10.3 `PersonajesScreen` y `PagoScreen`

- `PersonajesScreen`: envoltorio mínimo `const SafeArea(child: ConsultScreen())`.
- `PagoScreen`: `const Placeholder()`; **no está registrado en `router_admin.dart`**.
- `screen_admin.dart`: archivo barril con dos `export`.

### 10.4 `ConsultScreen` + `ImageCustom` (local)

- `ListView.separated` con `Divider(height: 1)` y `_characterTile`.
- `_characterTile`: `InkWell(onTap: () => sendToDetail(character.id.toString()))` → `Padding(12)` → `IntrinsicHeight` → `Row(crossAxisAlignment: stretch)` con:
  1. `ImageCustom(src: character.image)` (ancho 110, `ClipRRect(radius 12)`),
  2. `SizedBox(width: 12)`,
  3. `Expanded > Column` con nombre (`maxLines: 1`, `ellipsis`, `w600`), `'Raza: ...'`, `'Ki: ...'`,
  4. `SizedBox(width: 8)` + `Center(Icon(Icons.chevron_right))`.
- **`ImageCustom` está declarada al final de `consult_screen.dart`**, no en `shared/`: usa `Image.network` con `errorBuilder` y `loadingBuilder` propios. Al replicar, respeta esa duplicidad (o extrae a shared solo si se pide explícitamente).

### 10.5 `DetailScreen`

- `Scaffold(body: SafeArea(child: _buildBody()))`.
- Construye `sliderItems`: primero la imagen del personaje (`subtitle: 'Personaje'`) y luego `_transformations.map(...)` (`subtitle: 'Transformación'`).
- `ImageSlider(key: ValueKey(character.id), ...)`: la `ValueKey` fuerza a reiniciar el slider al cambiar de personaje.
- Contenido: `SingleChildScrollView(padding: EdgeInsets.all(16)) > Column` con nombre (`headlineSmall` + bold), `Wrap` de `_chip(...)` para raza, género, Ki, Ki máx y afiliación (solo si el valor no está vacío), descripción justificada y "Planeta de origen".
- `_chip(String label) => Chip(label: Text(label))`.

### 10.6 `ImageSlider` (`shared/images/images_widget.dart`)

Widget reutilizable con estado propio:

- `SliderImage` (url/label/subtitle) es la data class, `const`.
- `ImageSlider extends StatefulWidget`: `items`, `height = 320`, `PageController` + `int _currentPage`, `dispose()` del controlador.
- `_goTo(index)` usa `_controller.animateToPage(index, duration: 300ms, curve: Curves.easeInOut)`.
- `build`: `SizedBox(height)` → `Stack` con `PageView.builder` + flechas `IconButton.filledTonal` (`Icons.chevron_left/right`, deshabilitadas en los extremos); luego subtitle en mayúsculas (`labelSmall`, `letterSpacing: 1.2`), label (`titleMedium` bold), contador `'${current + 1} / ${items.length}'` y puntos indicadores con `Wrap > GestureDetector > AnimatedContainer(250ms, ancho 20/8, color primary/outlineVariant)`.
- `_SliderPicture` privado: `Image.network(fit: BoxFit.contain)` con `errorBuilder` → `Icon(Icons.image_not_supported, size: 48)` y `loadingBuilder` → `CircularProgressIndicator(strokeWidth: 2)`.

### 10.7 `ErrorRetryWidget`

`Center > SingleChildScrollView(24) > Column(mainAxisSize: min)` con `Icon(Icons.cloud_off_rounded, size: 64, color: colorScheme.error)`, el mensaje centrado y `FilledButton.icon(icon: Icons.refresh, label: 'Reintentar', onPressed: onRetry)`.

### 10.8 `ProfileScreen`

- Misma máquina de estados (§9) con `ProfileModel? profile`.
- Tres variantes de build (loading, error, normal) que repiten `Scaffold(body: SingleChildScrollView(padding: EdgeInsets.all(20), child: ...))`.
- `_placeholder()` construye un `ProfileModel.fromJson(const {...})`.
- `_content`: `CircleAvatar(radius: 65)` dentro de un `Container` con `BoxShadow`, nombre (`headlineSmall`), `@username`, y una tarjeta `Container(padding: 20, borderRadius: 18, boxShadow ...)` con cinco `_item(...)` separados por `Divider()`.
- `_item({required BuildContext context, required IconData icon, required String label, required String value})`: `Row > Icon(icon, color: primary, size: 26) + SizedBox(15) + Expanded(Column(label 13px atenuado, value bodyLarge w600))`.
- Usa la API nueva de color: `Colors.black.withValues(alpha: 0.25)` (no `withOpacity`).

---

## 11. Convenciones de código (reglas para una IA)

1. **Imports absolutos** con el nombre del paquete: `import 'package:cuenta/...';`. Nunca imports relativos (`../`).
2. **Comillas simples** en Dart, salvo cuando la cadena contiene comillas simples (p. ej. `withValues(alpha: 0.25)` u otros strings literales con `'`).
3. **Nombres:**
   - Pantallas terminan en `Screen`; widgets reutilizables en `Widget`.
   - Servicios terminan en `Service`; modelos en `Model`.
   - Todo helper privado empieza con `_` (incluidas las clases de estado `_XScreenState` y `_SliderPicture`).
   - Archivos en `snake_case`.
4. **`const` donde sea posible**: constructores `const`, `SizedBox`, `Divider`, `EdgeInsets`, `Text` estáticos, listas `const [...]`. Si el modelo no tiene constructor const, la pantalla tampoco.
5. **Dio:** un `_dio` `static final` por servicio, `BaseOptions` con los tres timeouts de `NetworkConfig`, `static final url`, `try { ... } on DioException catch (e)`.
6. **Errores:** siempre `ApiException` con mensaje en español; nunca mostrar `e.toString()` de Dio en la UI.
7. **Modelos:** `factory fromJson(dynamic json)`, validación `is Map`, helpers `_asString` / `_asInt`, degradación silenciosa a `''` / `0` / `const []`. Sin generadores de código.
8. **Estado:** local con `setState` en pantallas de datos; Riverpod **solo** para el tema; `if (!mounted) return;` después de cada `await`.
9. **UI:** `Theme.of(context).colorScheme` / `textTheme` para colores y tipografía; espaciado con `SizedBox`; `Wrap` para chips; `ClipRRect` + `Image.network` con `errorBuilder`/`loadingBuilder` para imágenes remotas.
10. **Navegación:** `context.go` para cambio de raíz (login/logout/drawer), `context.push` para detalle; rutas declaradas en `routerConfigAdmin` con `RouterModel`.
11. **Sin** `Repository`,BLoC, `get_it`, `json_serializable`, `equatable`, animaciones personalizadas ni tests unitarios en la raíz.
12. **Idioma:** todos los textos visibles para el usuario en español.

---

## 12. Recetas para replicar (plantillas fieles al estilo)

### 12.1 Añadir una pantalla de listado con API

1. Crear `lib/model/admin/<cosa>_model.dart` con `fromJson` + `_asString`/`_asInt`.
2. Crear `lib/services/admin/<cosa>/<cosa>_service.dart` con Dio estático, interceptor, `url` y `static Future<List<...>> get...()`.
3. Crear `lib/presentation/admin/<cosa>/consult_screen.dart` copiando la máquina de estados de `consult_screen.dart` (§9) y un `_buildTile(...)` privado.
4. Crear el envoltorio `<cosa>_screen.dart` con `SafeArea(child: ConsultScreen())`.
5. Registrar en `router_admin.dart`:

```dart
RouterModel(
  name: 'Cosas',
  screen: (context, state) => const CosasScreen(),
  title: 'Cosas',
  patch: '/admin/cosas',
  icon: Icons.shelves,
  description: '',
),
```

6. El drawer y el `AppBar` se actualizan solos por `inDrawer`/`topRoute?.name`.

### 12.2 Añadir un endpoint a un servicio existente

```dart
static Future<Model> getAlgo(String id) async {
  try {
    final response = await _dio.get('$url/recursos/$id');
    final data = response.data;

    if (data is! Map) {
      throw const ApiException('Respuesta inválida del servidor');
    }
    return Model.fromJson(data);
  } on DioException catch (e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == 400 || statusCode == 404) {
      throw ApiException('Recurso no encontrado', statusCode: statusCode);
    }
    throw ApiException.fromDio(e);
  }
}
```

### 12.3 Añadir un widget reutilizable

- Archivo en `lib/presentation/shared/` (o subcarpeta, como `shared/images/`).
- Data class `const` si hace falta + `Widget extends StatelessWidget/StatefulWidget` con constructor `const` y parámetros `final`.
- `StatefulWidget` → clase de estado privada `_{Name}State`, controladores `final`, `dispose()`.
- Colores siempre desde `Theme.of(context).colorScheme`; helpers de construcción privados.

### 12.4 Persistir una nueva preferencia

Copiar `theme_provider.dart`: `StateNotifierProvider<..., bool>`, `StateNotifier` con carga en el constructor desde `SharedPreferences`, método que muta `state` y escribe, y `ref.watch` en el widget que lo necesite (importando `package:flutter_riverpod/legacy.dart`).

---

## 13. Estado real de compilación / análisis (verificado)

- `flutter pub get` → correcto. Resuelve `flutter_riverpod 3.4.3`, `go_router 16.3.0`, `dio 5.9.0` estándar, `skeletonizer 2.1.3`, etc. (las versiones `^` pueden subir dentro del rango).
- `flutter analyze lib` → **"No issues found"**.
- `flutter analyze` **sin argumentos desde la raíz** → **falla con 43 issues**, todos procedentes de `clase/`: el analizador raíz entra en el proyecto anidado porque `analysis_options.yaml` solo excluye `build/**`, `android/**`, `ios/**`, `web/**`, `windows/**`, `macos/**`, `linux/**` y **no** `clase/**`.
  - Consecuencia: para verificar solo esta app, usa `flutter analyze lib`.
  - Solución opcional (no aplicada): añadir `- clase/**` al `analyzer.exclude` de `analysis_options.yaml`.
- No hay carpeta `test/` en la raíz.

---

## 14. Limitaciones, deudas y precisiones importantes

| Ítem | Realidad |
|---|---|
| Creación de productos | No implementada a propósito: `POST /api/characters` de DBZ requiere JWT propio → `401`. No simular éxito. |
| `AuthNotifier` (`helpers/token.dart`) | Código muerto. No conectarlo al router ni a la UI. |
| `ImageCustom` | Duplicada: una local en `consult_screen.dart` y `_SliderPicture` privada en `images_widget.dart`. |
| `router_model.dart` | El campo se llama **`patch`**, no `path`. Mantener el nombre al registrar nuevas rutas. |
| `title` y `description` de `RouterModel` | Se rellenan pero no se usan en la UI actual. |
| `drawer_widget.dart` | Datos de integrantes hardcodeados; filtro `inDrawer` aplicado dos veces. |
| `FlutterSecureStorage` | Hay tres instancias distintas (global en `router_config.dart`, static en `AuthInterceptor`, static en `AuthService`/`ProfileService`, local en el logout). Todas apuntan a la misma clave `'token'`. |
| Sesión | No hay refresh ni expiración local: un `401` borra el token y manda al login. |
| `profile_service.dart` | `getProfile()` es de instancia; los otros dos servicios son estáticos. |
| Tema | El toggle solo existe en `AuthScreen`; no hay selector en el drawer. |
| Scaffolds anidados | `ShellRoute > Layout(Scaffold)` y cada pantalla hija crea otro `Scaffold`. Es así en el original. |
| Localización | `supportedLocales` solo `es`; los textos no están en archivos ARB. |
| `clase/` | Proyecto independiente con su propio `pubspec.yaml`; excluido de esta documentación y del análisis útil de la app. |

---

## 15. Índice rápido archivo → responsabilidad

| Archivo | Responsabilidad |
|---|---|
| `lib/main.dart` | Binding, flag de GoRouter, `ProviderScope`, `MaterialApp.router` |
| `lib/config/router/router_config.dart` | GoRouter, guardia de token, `ShellRoute`, storage global |
| `lib/config/router/router_admin.dart` | Catálogo de rutas admin (`RouterModel`) |
| `lib/config/router/router_model.dart` | DTO de ruta |
| `lib/config/theme/app_theme.dart` | `ThemeData` Material 3 por semilla de color |
| `lib/helpers/api_exception.dart` | Errores de dominio y mapeo de `DioException` |
| `lib/helpers/interceptor.dart` | Bearer token + logout en 401 |
| `lib/helpers/jwt_helper.dart` | Extraer `sub` del JWT |
| `lib/helpers/network_config.dart` | Timeouts |
| `lib/helpers/token.dart` | `AuthNotifier` (sin uso) |
| `lib/model/admin/character_model.dart` | Personaje + transformación, parseo defensivo |
| `lib/model/admin/profile_model.dart` | Perfil de Fake Store |
| `lib/model/auth/auth_model.dart` | Token de login |
| `lib/providers/theme_provider.dart` | Tema persistido con SharedPreferences |
| `lib/services/auth/auth_service.dart` | `POST /auth/login` + escritura de token |
| `lib/services/admin/profile/profile_service.dart` | `GET /users/{id}` |
| `lib/services/admin/personajes/personajes_service.dart` | `GET /characters` paginado + `GET /characters/{id}` |
| `lib/presentation/public/auth/auth_screen.dart` | Login + toggle de tema |
| `lib/presentation/admin/layout/layout.dart` | Shell con AppBar y Drawer |
| `lib/presentation/admin/layout/drawer_widget.dart` | Menú desde el router + logout |
| `lib/presentation/admin/personajes/*` | Listado y detalle de personajes |
| `lib/presentation/admin/profile/profile_screen.dart` | Perfil del usuario |
| `lib/presentation/shared/error_retry_widget.dart` | Error + reintento |
| `lib/presentation/shared/images/images_widget.dart` | Carrusel de imágenes |
