CREATE DATABASE IF NOT EXISTS examen_videojuegos CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE examen_videojuegos;

-- =============================================================
-- Base de datos de la app "cuenta" con temática de videojuegos.
-- Los atributos del modelo de DBZ se reutilizan renombrados:
--   name -> nombre, race -> género, affiliation -> desarrolladora,
--   originPlanet -> pais_origen, description -> descripción, image -> imagen.
-- Reimportable: se eliminan primero las tablas en orden (hija antes que padre).
-- =============================================================

DROP TABLE IF EXISTS dlc;
DROP TABLE IF EXISTS videojuego;
DROP TABLE IF EXISTS usuario;

CREATE TABLE usuario (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password CHAR(64) NOT NULL,
  email VARCHAR(100) NOT NULL,
  nombre VARCHAR(60) NOT NULL,
  apellido VARCHAR(60) NOT NULL,
  telefono VARCHAR(30) NOT NULL,
  ciudad VARCHAR(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE videojuego (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL,
  genero VARCHAR(60) NOT NULL,
  plataforma VARCHAR(80) NOT NULL,
  calificacion DECIMAL(3,1) NOT NULL,
  precio DECIMAL(8,2) NOT NULL,
  desarrolladora VARCHAR(100) NOT NULL,
  pais_origen VARCHAR(60) NOT NULL,
  descripcion TEXT NOT NULL,
  imagen VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE dlc (
  id INT AUTO_INCREMENT PRIMARY KEY,
  videojuego_id INT NOT NULL,
  nombre VARCHAR(120) NOT NULL,
  imagen VARCHAR(255) NOT NULL,
  CONSTRAINT fk_dlc_videojuego FOREIGN KEY (videojuego_id) REFERENCES videojuego(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------------
-- Usuarios: password = hash SHA-256 calculado por el propio MySQL
-- -------------------------------------------------------------
INSERT INTO usuario (username, password, email, nombre, apellido, telefono, ciudad) VALUES
('admin', SHA2('admin123', 256), 'andres.ramirez@examen-videojuegos.com', 'Andrés', 'Ramírez', '+57 300 123 4567', 'Ocaña'),
('demo',  SHA2('demo123',  256), 'daniela.perez@examen-videojuegos.com', 'Daniela', 'Pérez',   '+57 301 987 6543', 'Medellín');

-- -------------------------------------------------------------
-- Videojuegos (IDs 1 a 12; los DLC se asocian a esos IDs)
-- -------------------------------------------------------------
INSERT INTO videojuego (id, nombre, genero, plataforma, calificacion, precio, desarrolladora, pais_origen, descripcion, imagen) VALUES
(1, 'The Witcher 3: Wild Hunt', 'RPG de acción mundo abierto', 'PC, PlayStation 4, Xbox One', 9.8, 39.99, 'CD Projekt Red', 'Polonia',
'Geralt de Rivia busca a su hija adoptiva Ciri en un continente
asolado por la guerra y criaturas salvajes. Cada decisión
modifica el destino de los personajes y el mundo que les rodea.',
'https://picsum.photos/seed/the-witcher-3-wild-hunt/600/400'),

(2, 'The Legend of Zelda: Breath of the Wild', 'Acción-aventura mundo abierto', 'Nintendo Switch, Wii U', 9.7, 59.99, 'Nintendo EPD', 'Japón',
'Link despierta tras cien años de sueño en un Hyrule en ruinas.
Explora campos, montañas y templos con libertad total para
recuperar sus recuerdos y derrotar al Rey Demonio Ganon.',
'https://picsum.photos/seed/zelda-breath-of-the-wild/600/400'),

(3, 'Dark Souls III', 'RPG de acción', 'PC, PlayStation 4, Xbox One', 9.2, 59.99, 'FromSoftware', 'Japón',
'El fuego se apaga y los señores de las cenizas han fracasado.
Recorre Lothric entre jefes implacables, aprende sus patrones
y decide si merece la pena volver a encender la hoguera.',
'https://picsum.photos/seed/dark-souls-3/600/400'),

(4, 'Fallout 4', 'RPG postapocalíptico', 'PC, PlayStation 4, Xbox One', 9.0, 49.99, 'Bethesda Game Studios', 'Estados Unidos',
'Tras la bomba, Nate o Nora emergen del refugio 111 en un
Boston irradiado. Busca a tu hijo, reconstruye asentamientos
y sobrevive mientras mutantes y supersoldados acechan.',
'https://picsum.photos/seed/fallout-4/600/400'),

(5, 'The Elder Scrolls V: Skyrim', 'RPG de fantasía', 'PC, PlayStation 4, Xbox One, Nintendo Switch', 9.6, 49.99, 'Bethesda Game Studios', 'Estados Unidos',
'Un dragonborn recién llegado a Skyrim descubre que es capaz
de absorber las almas de los dragones. Recorre la provincia,
domina las artes del dragón y decide el futuro del país.',
'https://picsum.photos/seed/the-elder-scrolls-v-skyrim/600/400'),

(6, 'Assassin''s Creed Odyssey', 'RPG de acción histórico', 'PC, PlayStation 4, Xbox One, Nintendo Switch', 9.0, 59.99, 'Ubisoft Quebec', 'Canadá',
'En la Grecia clásica, un mercenario espartano se adentra
en la guerra del Peloponeso. Explora islas, ciudades y templos,
elige bando y desentierra la conspiración de los Cultistas.',
'https://picsum.photos/seed/assassins-creed-odyssey/600/400'),

(7, 'Hollow Knight', 'Metroidvania de plataformas', 'PC, Nintendo Switch, PlayStation 4, Xbox One', 9.4, 14.99, 'Team Cherry', 'Australia',
'Un caballero sin nombre baja a las profundidades de Hallownest,
un reino afectado por una plaga. Explora cuevas interconectadas,
domina hechizos y descubre los secretos del Rey Radiante.',
'https://picsum.photos/seed/hollow-knight/600/400'),

(8, 'XCOM 2', 'Estrategia por turnos', 'PC, PlayStation 4, Xbox One, Nintendo Switch', 9.1, 59.99, 'Firaxis Games', 'Estados Unidos',
'La humanidad vive bajo el yugo de los alienígenas desde hace
veinte años. Dirige a los soldados de la Resistencia en misiones
tácticas por turnos para recuperar la Tierra.',
'https://picsum.photos/seed/xcom-2/600/400'),

(9, 'Red Dead Redemption 2', 'Acción-aventura', 'PlayStation 4, Xbox One, PC', 9.6, 59.99, 'Rockstar Games', 'Estados Unidos',
'En el oeste de 1899, Arthur Morgan viaja con la banda Van der Linde
mientras el mundo cambia a su alrededor. Caza, cabalga y cuida
de los suyos en una de las aventuras más amplias del género.',
'https://picsum.photos/seed/red-dead-redemption-2/600/400'),

(10, 'Grand Theft Auto V', 'Acción-aventura mundo abierto', 'PC, PlayStation 4, Xbox One', 9.4, 29.99, 'Rockstar Games', 'Estados Unidos',
'Tres criminales de Los Santos planean golpes cada vez más
ambiciosos mientras intentan sobrevivir en la ciudad.
Alterna entre sus historias y recorre un mundo abierto satírico.',
'https://picsum.photos/seed/grand-theft-auto-v/600/400'),

(11, 'God of War', 'Acción-aventura', 'PlayStation 4, PC', 9.7, 49.99, 'Santa Monica Studio', 'Estados Unidos',
'Kratos y su hijo Atreus recorren los reinos nórdicos para
cumplir la última voluntad de su esposa. Enfrenta a dioses
y monstruos mientras le enseña a cazar y a perdonar.',
'https://picsum.photos/seed/god-of-war-2018/600/400'),

(12, 'Stardew Valley', 'Simulación de granja', 'PC, Nintendo Switch, PlayStation 4, Xbox One', 9.5, 14.99, 'ConcernedApe', 'Estados Unidos',
'Dejas la ciudad para heredar una granja abandonada en el valle.
Siembra cultivos, cría animales, pesca y entabla amistad
con los vecinos mientras reconstruyes tu nueva vida.',
'https://picsum.photos/seed/stardew-valley/600/400');

-- -------------------------------------------------------------
-- DLC reales: 8 juegos tienen DLC (2 o 3 cada uno) y 4 no tienen.
-- -------------------------------------------------------------
INSERT INTO dlc (videojuego_id, nombre, imagen) VALUES
(1, 'Hearts of Stone', 'https://picsum.photos/seed/witcher-hearts-of-stone/600/400'),
(1, 'Blood and Wine', 'https://picsum.photos/seed/witcher-blood-and-wine/600/400'),
(2, 'The Master Trials', 'https://picsum.photos/seed/zelda-master-trials/600/400'),
(2, 'The Champions'' Tapestry', 'https://picsum.photos/seed/zelda-champions-tapestry/600/400'),
(3, 'Ashes of Ariandel', 'https://picsum.photos/seed/dark-souls-ashes-of-ariandel/600/400'),
(3, 'The Ringed City', 'https://picsum.photos/seed/dark-souls-ringed-city/600/400'),
(4, 'Automatron', 'https://picsum.photos/seed/fallout-automatron/600/400'),
(4, 'Wasteland Workshop', 'https://picsum.photos/seed/fallout-wasteland-workshop/600/400'),
(4, 'Far Harbor', 'https://picsum.photos/seed/fallout-far-harbor/600/400'),
(5, 'Dawnguard', 'https://picsum.photos/seed/skyrim-dawnguard/600/400'),
(5, 'Hearthfire', 'https://picsum.photos/seed/skyrim-hearthfire/600/400'),
(5, 'Dragonborn', 'https://picsum.photos/seed/skyrim-dragonborn/600/400'),
(6, 'The Fate of Atlantis', 'https://picsum.photos/seed/odyssey-fate-of-atlantis/600/400'),
(6, 'The Lost Tales of Greece', 'https://picsum.photos/seed/odyssey-lost-tales-of-greece/600/400'),
(7, 'Hidden Dreams', 'https://picsum.photos/seed/hollow-hidden-dreams/600/400'),
(7, 'The Grimm Troupe', 'https://picsum.photos/seed/hollow-grimm-troupe/600/400'),
(7, 'Godmaster', 'https://picsum.photos/seed/hollow-godmaster/600/400'),
(8, 'Alien Hunters', 'https://picsum.photos/seed/xcom-alien-hunters/600/400'),
(8, 'Shen''s Last Gift', 'https://picsum.photos/seed/xcom-shens-last-gift/600/400'),
(8, 'War of the Chosen', 'https://picsum.photos/seed/xcom-war-of-the-chosen/600/400');
