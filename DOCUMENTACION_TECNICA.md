# Documentación Técnica — Frog Adventure

---

## 1. Introducción y Objetivos

**Frog Adventure** es un videojuego de plataformas 2D con estética pixel-art desarrollado en Godot Engine 4.6. El jugador controla a una rana ninja que debe recorrer un nivel de bosque lateral (side-scrolling), recolectando frutas y estrellas mientras evita o derrota enemigos.

### Objetivos del nivel

- Recolectar todos los melones (+1 punto cada uno)
- Derrotar enemigos saltando sobre ellos (+3 puntos) o lanzando shurikens (+1 punto)
- Alcanzar y recoger la estrella dorada (+5 puntos) para completar el nivel
- Conservar las 3 vidas iniciales; al perderlas todas, la partida termina

---

## 2. Ficha Técnica

| Elemento | Valor |
|----------|-------|
| **Motor** | Godot Engine 4.6 |
| **Lenguaje** | GDScript |
| **Renderer** | GL Compatibility |
| **Resolución nativa** | 426 × 240 píxeles |
| **Resolución de ventana** | 1200 × 700 píxeles |
| **Modo de estiramiento** | `canvas_items` |
| **Filtro de texturas** | Nearest (sin suavizado, pixel-art) |
| **Plataformas** | Windows, macOS, Linux, Web (HTML5) |
| **Versión de configuración** | 5 |
| **Física 2D** | Capas personalizadas (World, Player, Enemies, Pickups) |

---

## 3. Estructura del Proyecto

```
Frog Adventure/
├── project.godot                    # Configuración del proyecto
├── README.md                        # Documentación del juego
├── icon.svg                         # Icono de la aplicación
├── scenes/                          # Escenas (.tscn)
│   ├── menu.tscn                    # Menú principal
│   ├── world.tscn                   # Nivel principal
│   ├── gui.tscn                     # Interfaz de usuario (HUD)
│   ├── player.tscn                  # Personaje principal (rana ninja)
│   ├── goblin.tscn                  # Enemigo terrestre (goblin patrullero)
│   ├── bee.tscn                     # Enemigo aéreo (abeja)
│   ├── plant_c.tscn                 # Enemigo estático (planta carnívora)
│   ├── melon.tscn                   # Coleccionable (melón)
│   ├── star.tscn                    # Coleccionable especial (estrella)
│   ├── shuriken.tscn                # Proyectil de ataque
│   └── parallax_background.tscn     # Fondo con efecto parallax
├── scripts/                         # Scripts de lógica (.gd)
│   ├── player.gd                    # Control del personaje
│   ├── slug.gd                      # IA de patrullaje (usado por goblin)
│   ├── bee.gd                       # IA de patrullaje aéreo
│   ├── plant_c.gd                   # IA de detección por proximidad
│   ├── shuriken.gd                  # Lógica del proyectil
│   ├── hud.gd                       # Gestión del HUD (pausa, victoria, muerte)
│   ├── menu.gd                      # Lógica del menú principal
│   └── star.gd                      # Detección de recolección de estrella
└── assets/                          # Recursos gráficos y de audio
    ├── player/                      # Sprites del personaje (idle, run, jump, hurt)
    ├── goblin/                      # Sprites del goblin (run, idle, death)
    ├── enemies/                     # Sprites de abeja, planta, slug
    ├── Fruits/                      # Sprites de frutas (melón, manzana, etc.)
    ├── pickups/                     # Sprites de coleccionables (star, carrot)
    ├── world/                       # Tileset, fondos, decoraciones, props
    ├── Boxes/                       # Sprites de cajas destructibles
    ├── Checkpoints/                 # Sprites de checkpoints
    ├── slime/                       # Sprites de slime
    ├── mushroom/                    # Sprites de hongo
    ├── hud elements/                # Elementos de UI (corazones, monedas, fuente)
    ├── music/                       # Música de fondo (.ogg)
    ├── inicio.png                   # Fondo del menú principal
    ├── inicio.mp3                   # Música del menú
    ├── start.mp3                    # Sonido al iniciar partida
    └── m6x11plus.ttf                # Fuente pixel-art del juego
```

---

## 4. Mecánicas Principales

### 4.1 Parámetros del Personaje

| Parámetro | Valor | Descripción |
|-----------|-------|-------------|
| Velocidad de movimiento | **110.0** px/s | Velocidad horizontal máxima |
| Fuerza de salto | **-200.0** px/s | Impulso vertical al saltar |
| Gravedad | **300** px/s² | Gravedad personalizada (hardcodeada) |
| Vidas iniciales | **3** | Reinicio al menú al llegar a 0 |
| Puntuación inicial | **0** | Acumula puntos por acciones |
| Tiempo de invulnerabilidad | **0.5 s** | Tras recibir daño |
| Retroceso al recibir daño | **-100.0** px/s | 50% de la fuerza de salto |
| Cooldown de shuriken | **0.4 s** | Tiempo entre disparos |
| Offset de aparición del shuriken | **20 px** | Distancia desde el centro del jugador |

### 4.2 Mecánicas de Interacción

| Interacción | Condición | Resultado |
|-------------|-----------|-----------|
| **Recolectar melón** | El Hitbox del jugador solapa el Area2D del melón | +1 punto, el melón desaparece |
| **Recolectar estrella** | El jugador entra en el área de la estrella | +5 puntos, panel "YOU WIN", pausa |
| **Saltar sobre enemigo** | Centro del jugador ≥ 18px arriba del centro del enemigo | +3 puntos, enemigo muere (animación), jugador rebota |
| **Colisión lateral con enemigo** | Cualquier otra colisión jugador-enemigo | -1 vida, animación "hurt", retroceso, 0.5s invulnerable |
| **Lanzar shuriken** | Presionar tecla E (con cooldown disponible) | Proyectil recorre 15px, mata enemigos al contacto (+1 punto) |
| **Sin vidas** | `lives ≤ 0` | Panel "GAME OVER" con puntaje final, botón "Volver a intentar" |
| **Pausa** | Presionar ESC | Pausa/reanuda el juego, muestra "PAUSED" |

### 4.3 Comportamiento de Enemigos

| Enemigo | Tipo de Nodo | Movimiento | Velocidad | Detección |
|---------|-------------|------------|-----------|-----------|
| **Goblin** | CharacterBody2D | Patrullaje horizontal, rebota en paredes (RayCast2D) | 20 px/s | Colisión con jugador |
| **Abeja** | Area2D | Patrullaje horizontal en rango limitado (±20 px desde inicio) | 30 px/s | Colisión con jugador |
| **Planta carnívora** | Area2D | Estática, cambia animación por proximidad del jugador (Zona de detección 80×60 px) | 0 px/s | `body_entered` → anim "attack"; `body_exited` → anim "idle" |

### 4.4 Capas de Colisión (2D Physics)

| Capa | Bit | Valor | Uso |
|------|-----|-------|-----|
| Layer 1 — **World** | 0 | 1 | TileMap (suelo y plataformas) |
| Layer 2 — **Player** | 1 | 2 | Personaje principal |
| Layer 3 — **Enemies** | 2 | 4 | Todos los enemigos |
| Layer 4 — **Pickups** | 3 | 8 | Coleccionables (melones, estrella) |

---

## 5. Configuración de Input

| Acción | Tecla Principal | Tecla Alternativa | Descripción |
|--------|----------------|-------------------|-------------|
| `ui_left` | ← (Flecha izquierda) | A | Moverse a la izquierda |
| `ui_right` | → (Flecha derecha) | D | Moverse a la derecha |
| `ui_up` | ↑ (Flecha arriba) | W | Moverse arriba |
| `ui_down` | ↓ (Flecha abajo) | S | Moverse abajo |
| `ui_accept` | Espacio | Enter (por defecto Godot) | Saltar |
| `ui_cancel` | Escape | — (por defecto Godot) | Pausar / Reanudar |
| `shoot` | E | — | Lanzar shuriken |

---

## 6. Sistema de Señales y Conexiones

### 6.1 Escena: `player.tscn`

| Señal | Emisor (from) | Receptor (to) | Método | Propósito |
|-------|--------------|---------------|--------|-----------|
| `area_entered` | `Hitbox` (Area2D) | `Player` | `_on_hitbox_area_entered` | Detectar coleccionables y enemigos tipo Area2D |
| `body_entered` | `Hitbox` (Area2D) | `Player` | `_on_hitbox_body_entered` | Detectar enemigos tipo CharacterBody2D |

### 6.2 Escena: `plant_c.tscn`

| Señal | Emisor (from) | Receptor (to) | Método | Propósito |
|-------|--------------|---------------|--------|-----------|
| `body_entered` | `DetectionZone` (Area2D) | `splant_c` | `_on_detection_zone_body_entered` | Cambiar a animación "attack" |
| `body_exited` | `DetectionZone` (Area2D) | `splant_c` | `_on_detection_zone_body_exited` | Cambiar a animación "idle" |

### 6.3 Escena: `gui.tscn` (Conexiones por código en `hud.gd`)

| Señal | Emisor | Método | Propósito |
|-------|--------|--------|-----------|
| `pressed` | `BackButton` (WinPanel) | `_on_back_pressed()` | Volver al menú principal tras ganar |
| `pressed` | `RetryButton` (DeathPanel) | `_on_retry_pressed()` | Reiniciar el nivel tras morir |

### 6.4 Escena: `menu.tscn`

| Señal | Emisor (from) | Receptor (to) | Método | Propósito |
|-------|--------------|---------------|--------|-----------|
| `pressed` | `StartButton` | `Menu` | `_on_start_pressed()` | Iniciar partida |
| `pressed` | `QuitButton` | `Menu` | `_on_quit_pressed()` | Salir del juego |

### 6.5 Escena: `shuriken.tscn` (Conexiones por código en `shuriken.gd`)

| Señal | Emisor | Método | Propósito |
|-------|--------|--------|-----------|
| `body_entered` | `Hitbox` (Area2D) | `_on_hit()` | Destruir enemigo CharacterBody2D al contacto |
| `area_entered` | `Hitbox` (Area2D) | `_on_hit()` | Destruir enemigo Area2D al contacto |
| `timeout` | `Timer` | `queue_free` | Autodestrucción del shuriken a los 0.5s |

### 6.6 Resumen de Flujo de Señales

```
Jugador toca enemigo
  │
  ├─ Hitbox.area_entered / body_entered
  │     └─ _check_enemy_collision(enemy)
  │           ├─ ¿Jugador arriba? → enemy.die() → animación muerte → queue_free()
  │           └─ ¿Colisión lateral? → take_damage() → hurt, -1 vida

Jugador toca pickups
  │
  ├─ Hitbox.area_entered → grupo "star" → show_win(score)
  └─ Hitbox.area_entered → grupo "pickups" → add_score(1)

Jugador presiona E
  │
  └─ _handle_shoot() → instanciar shuriken → shuriken vuela 15px
        └─ Hitbox.body_entered / area_entered → enemigo muere (+1 pt)
```
