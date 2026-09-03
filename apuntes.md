# Apuntes de repaso: Colores, Tipografía, ITCSS, OOCSS y Atomic Design

> Este archivo es para ti. Recoge las ideas clave que hemos trabajado en este proyecto (3-column preview card) para que puedas repasarlas y volver a aplicarlas en el próximo reto, sin depender de recordar todo de memoria.

---

## 1. Sistema de colores (tokens de diseño)

La idea central: **nunca usar un valor de color "pelado" (`#e38826`) directamente en un componente**. Se pasa por dos capas:

```css
/* assets/styles/01-settings/colors.css */
:root {
    /* 1. PRIMITIVOS: el valor crudo, con nombre descriptivo del color real */
    --color-primary-gold-100: #e38826;
    --color-primary-cyan-800: #006970;
    --color-primary-green-950: #004241;
    --color-neutral-grey-100: hsl(0, 0%, 95%);
    --color-neutral-white-75: hsla(0, 0%, 100%, 0.75);

    /* 2. TOKENS SEMÁNTICOS: dicen para QUÉ se usa el color, no CUÁL es */
    --color-bg-card-sedans: var(--color-primary-gold-100);
    --color-text-headings: var(--color-neutral-grey-100);
}
```

**¿Por qué dos capas y no una?**
- Si el diseño cambia el dorado por otro tono, tocas **una sola línea** (el primitivo) y se propaga a todos los tokens semánticos que lo usan.
- El nombre semántico (`--color-bg-card-sedans`) le dice a cualquiera que lea el CSS *la intención*, sin tener que saber qué color es. Esto es el mismo principio que aplicamos en tipografía y espaciado.

**Preguntas para repasar:**
- ¿Por qué `--color-text-button-sedans` reutiliza `--color-primary-gold-100` en vez de crear un valor nuevo?
- Si mañana agregas un cuarto color de tarjeta, ¿qué línea(s) tocarías primero?

### 1.1 ¿Un archivo o varios para primitivos + tokens?

No hay una regla fija — depende del **tamaño del proyecto**, no de "la mejor práctica" universal:

- **Proyecto pequeño** (como este, ~5 primitivos y ~10 tokens): todo cabe cómodo en un solo `colors.css`, separado internamente con comentarios (`/* primary */`, `/* neutral */`, `/* tokens */`). Crear varios archivos para pocas líneas añade fricción para encontrar las cosas, no la reduce.
- **Proyecto grande** (un design system con decenas de colores y tokens): ahí sí conviene separar por **capas de abstracción**, no por categoría visual:
  1. `primitives.css` — los valores crudos.
  2. `tokens.css` (o `semantic.css`) — los alias que le dan significado (`--color-bg-card`, `--color-text-error`).
  3. Opcional: tokens *component-specific* (`--button-bg-hover`) cuando un componente tiene una necesidad muy particular que no encaja en lo semántico general.

  **Ojo:** la separación es por **nivel de abstracción** (primitivo → semántico → específico de componente), *no* por dónde se usa visualmente (fondo vs texto vs borde). Un archivo `color-bg.css` con solo "todos los fondos" mezcla primitivos y tokens de propósitos distintos — no resuelve nada, solo reparte el mismo problema en más sitios.

  Regla práctica: **divide un archivo cuando ya te duele mantenerlo junto** (se volvió largo, cuesta escanearlo), no antes de que eso pase.

### 1.2 El nombre del token describe la propiedad CSS, no solo "dónde se usa"

Un error fácil de cometer: nombrar un token por el elemento donde se usa (`--color-text-button`) sin verificar **qué propiedad CSS** va a recibir ese valor. En este proyecto, el gris claro del botón "Learn More" resultó ser el **`background-color`** del botón (no el `color` del texto) — el nombre correcto era `--color-bg-button`, no `--color-text-button`.

**Cómo evitarlo:** antes de nombrar, mira el diseño real (la imagen, no solo la descripción en `style-guide.md`) y pregúntate: ¿esto pinta el fondo, el texto, el borde? El prefijo (`bg-`, `text-`, `border-`) debe coincidir con la propiedad CSS real que vas a escribir.

### 1.3 El verdadero beneficio de un token no es "controlar cambios" — es desacoplar rol de valor

Trampa común de razonamiento: pensar que crear un token evita que un cambio en el primitivo se propague. **Eso es falso** — un token (`--color-bg-card-sedans: var(--color-primary-gold-100)`) sigue apuntando al primitivo, así que si el dorado cambia de tono, el token cambia igual que si hubieras usado el primitivo directo en el componente.

El beneficio real de crear un token por variante (`--color-bg-card-sedans`, `--color-bg-card-suvs`, `--color-bg-card-luxury`) en vez de usar los primitivos directamente en el CSS de cada tarjeta es otro: **desacoplar el rol del valor**. Si mañana decides que la tarjeta de "Sedans" ya no debería ser dorada sino de otro color de la paleta, con el token solo cambias **una línea** (a qué primitivo apunta `--color-bg-card-sedans`) sin tocar el CSS del componente ni renombrar nada. Sin el token, tendrías que ir al componente y cambiar qué primitivo usa directamente — funciona igual, pero mezcla "identidad de la tarjeta" con "valor de color" en el mismo lugar.

**Pista para decidir si algo necesita token propio:** si el primitivo ya tiene un nombre autoexplicativo para su rol (como `--color-primary-gold-100` siendo "el color de marca dorado"), un token no siempre añade claridad — pero si vas a *reasignar* ese valor a un elemento específico del diseño (una tarjeta, un estado), sí vale la pena, porque el nombre del token pasa a describir el **rol en el diseño** (`card-sedans`) en vez del **valor** (`gold`).

### 1.4 Convención de nombres para tokens: `--color-[propiedad]-[elemento]`

La plantilla que seguiste para nombrar cada token semántico:

```
--color-[propiedad]-[elemento]
         │            │
         │            └─ qué parte del diseño lo usa: body, headings, button, card-sedans...
         └─ qué propiedad CSS recibe el valor: bg, text, border...
```

Ejemplos de tu propio archivo:

```css
--color-bg-body            /* propiedad: bg    | elemento: body */
--color-text-headings      /* propiedad: text  | elemento: headings */
--color-bg-card-sedans     /* propiedad: bg    | elemento: card-sedans (variante) */
--color-text-button-suvs   /* propiedad: text  | elemento: button-suvs (variante) */
```

**Por qué es una buena práctica para llevarte a otros proyectos:**
- **Predecible**: si necesitas el color de borde de una tarjeta, ya sabes que probablemente se llama `--color-border-card`, sin tener que abrir el archivo a adivinar.
- **Auto-documentado**: el nombre solo, sin ver el valor, te dice en qué propiedad CSS va (conecta directo con el punto 1.2 — evita el error de nombrar por "dónde se usa" en vez de "qué propiedad pinta").
- **Escala bien con variantes**: cuando un mismo rol se repite por variante (tarjeta/estado/tamaño), el patrón se extiende de forma natural agregando el nombre de la variante al final (`-sedans`, `-suvs`, `-luxury`), sin inventar una convención nueva cada vez.
- **Autocompletado amigable**: en el editor, escribir `--color-bg-` te muestra de inmediato todos los tokens de fondo disponibles, agrupados por el prefijo.

Este mismo patrón se puede generalizar a otras propiedades más allá del color: `--font-[propiedad]-[elemento]` (como ya hiciste en tipografía: `--font-family-titles`), `--spacing-[propiedad]-[elemento]`, etc.

---

## 2. Tipografía como sistema, no como propiedad suelta

### 2.1 `@font-face`: cómo usar fuentes descargadas localmente

**El problema que resuelve:** `font-family: Arial;` funciona porque Arial ya está instalada en el dispositivo de quien visita la página. Fuentes como "Lexend Deca" o "Big Shoulders" no vienen instaladas en ningún lado — viven como archivos `.ttf` dentro de `assets/fonts/`. `@font-face` es la "tarjeta de presentación" que le dice al navegador: *"este nombre corresponde a este archivo, ve a buscarlo ahí"*.

**Ventaja / desventaja a tener en cuenta:** al usar fuentes locales te aseguras de que la fuente siempre esté disponible (no dependes de un servicio externo), pero el navegador tiene que descargar archivos extra, lo que puede retrasar la primera pintura del texto. Para eso existe `font-display: swap` (ver abajo).

**Anatomía mínima de la regla** (dos propiedades obligatorias):

```css
/* assets/styles/01-settings/fonts.css */
@font-face {
    font-family: "Lexend Deca";   /* el nombre que TÚ inventas, luego lo usas en font-family en cualquier otro selector */
    src: url("../../fonts/Lexend_Deca/static/LexendDeca-Regular.ttf"); /* dónde está el archivo */
    font-weight: 400;             /* qué peso representa ESTE archivo en concreto */
    font-display: swap;           /* mientras la fuente carga, muestra una de repuesto; en cuanto esté lista, la cambia (evita texto invisible) */
}

@font-face {
    font-family: "Big Shoulders";
    src: url("../../fonts/Big_Shoulders/static/BigShoulders-Bold.ttf");
    font-weight: 700;
    font-display: swap;
}
```

Puntos clave para no olvidar:
- **Comillas en `font-family`** cuando el nombre tiene espacio (`"Lexend Deca"`): sin comillas, CSS podría leer "Lexend" y "Deca" como dos palabras separadas en vez de un solo nombre.
- **La ruta dentro de `url()` es relativa al archivo CSS donde escribes la regla**, no a la raíz del proyecto. Para subir de carpeta se usa `../` (un `../` por cada nivel). Desde `assets/styles/01-settings/fonts.css` hasta `assets/fonts/...` hay que subir dos niveles: `../../`.
- **Un `@font-face` por cada peso/archivo que uses.** Si necesitas Lexend Deca en 400 y en 700, son dos bloques distintos (cada uno apuntando a su propio archivo `.ttf`), no uno solo con dos pesos.
- **`font-weight` debe coincidir con el archivo real** (usar el `.ttf` "Regular" con `font-weight: 400`, el "Bold" con `700`, etc.) — así, cuando luego pidas `font-weight: 700` en un selector, el navegador sabe exactamente qué archivo usar.
- **`font-style: italic`** existe para variantes en cursiva, pero solo hace falta declararlo si el diseño realmente pide texto en itálica (revisar `style-guide.md` primero).

**El error silencioso más común:** escribir un `fonts.css` perfecto pero que **nunca se carga** porque ningún otro archivo lo importa. En este proyecto, `styles.css` solo importa `settings.css` (no `fonts.css` directamente), así que hay que agregar `@import "./fonts.css";` **dentro de `settings.css`** para completar la cadena:

```
styles.css  →  @import settings.css  →  @import fonts.css
```

**Cómo comprobar que sí está funcionando:** DevTools → pestaña *Network* → filtrar por *Font* → recargar la página. Ojo: el navegador solo descarga el archivo cuando **algún elemento realmente usa esa fuente** (ej. `body { font-family: "Lexend Deca"; }`); solo declarar el `@font-face` no basta para verla en pantalla.

**Preguntas para repasar:**
- Si movieras `fonts.css` a la raíz de `assets/`, ¿cómo cambiaría la ruta relativa dentro de `url()`?
- ¿Qué pasaría si te olvidas de escribir `font-weight: 700` en el bloque de Big Shoulders, y luego usas `font-weight: 700;` en un `h1`?

### 2.2 El sistema de tokens de tipografía

Mismo patrón de dos capas usado en colores, aplicado a fuentes. Esta es la versión final a la que llegaste tras varias iteraciones:

```css
/* assets/styles/01-settings/typography.css */
:root {
    /* primitivos */
    --font-family-lexend-deca: "Lexend Deca", sans-serif;
    --font-family-big-shoulders: "Big Shoulders", sans-serif;
    --font-size-base: 15px;
    --font-size-title-base: 40px;
    --font-weight-lexend-deca-regular: 400;
    --font-weight-big-shoulders-bold: 700;
    --font-letter-spacing-title-base: 0.5px;

    /* tokens semánticos */
    --font-family-titles: var(--font-family-big-shoulders);
    --font-family-paragraphs: var(--font-family-lexend-deca);
    --font-weight-title: var(--font-weight-big-shoulders-bold);
    --font-weight-paragraph: var(--font-weight-lexend-deca-regular);
    --font-size-title: var(--font-size-title-base);
    --font-size-paragraph: var(--font-size-base);
    --font-letter-spacing-title: var(--font-letter-spacing-title-base);
}
```

Puntos clave:
- **`@font-face` vive aparte, en `fonts.css`**: es la "declaración de existencia" de la fuente (de dónde se descarga, qué peso representa). `typography.css` es la capa que decide *cómo se usa* esa fuente en el sistema. Separar ambos archivos evita mezclar "esta fuente existe" con "así es como se usa" en el mismo lugar.
- **Siempre incluir un fallback genérico** (`sans-serif`) en el `font-family`, por si la fuente tarda en cargar o falla.
- **`font-display: swap`** en `@font-face` evita texto invisible mientras carga la fuente (mejor accesibilidad/percepción de velocidad).
- Un `--font-size-base` en `px` o `rem` es tu punto de partida para construir una escala tipográfica (títulos, párrafos, etiquetas), en vez de inventar tamaños sueltos en cada componente.
- **`letter-spacing`** controla el espacio *entre letras* (no entre palabras) — útil en títulos con fuentes condensadas como Big Shoulders, donde el diseño suele separar un poco las letras para que no se vean apretadas (compáralo con `word-spacing`, que es distinto).
- Como con colores, **todo valor en el bloque de tokens semánticos debe apuntar a un primitivo con `var(...)`**, nunca un valor suelto — así, si `--font-size-title` tiene un valor hardcodeado en vez de `var(--font-size-title-base)`, rompe la consistencia del sistema aunque funcione visualmente igual.
- **Nombra igual el concepto en ambas capas.** Si el primitivo se llama `--font-size-title-base`, el token semántico debería llamarse `--font-size-title` (no mezclar sinónimos como "heading" en un lado y "title" en el otro) — facilita adivinar nombres sin abrir el archivo.

### 2.3 El bug silencioso: token semántico con el mismo nombre que su primitivo

Un error real que ocurrió en este proyecto al añadir `letter-spacing`:

```css
:root {
    /* primitivo */
    --font-letter-spacing-title-base: 0.5px;

    /* token semántico — mismo nombre exacto que el primitivo de arriba */
    --font-letter-spacing-title-base: var(--font-letter-spacing-title-base);
}
```

Como ambas declaraciones tienen **el nombre idéntico**, la segunda no "hereda" el valor de la primera — la **sobrescribe**, y encima intenta usar `var()` para referenciarse **a sí misma**. Una custom property de CSS no puede depender de su propio valor: cuando eso pasa, el navegador la trata como *guaranteed-invalid value*, es decir, la variable queda vacía/sin efecto, sin ningún error visible en consola.

**Cómo se detecta:** no hay warning llamativo — el síntoma es que la propiedad simplemente no aplica (el letter-spacing no se ve en pantalla) y toca revisar DevTools → *Computed* para notar que el valor no se resolvió.

**La corrección** fue simplemente dar nombres distintos a cada capa, igual que en todos los demás pares:

```css
--font-letter-spacing-title-base: 0.5px;                          /* primitivo */
--font-letter-spacing-title: var(--font-letter-spacing-title-base); /* token semántico */
```

**Lección general:** el patrón primitivo → token semántico solo funciona si **cada capa tiene su propio nombre**. Es un error fácil de cometer justo cuando el primitivo y el token describen "lo mismo" (como un único valor de letter-spacing) y da la tentación de no diferenciarlos.

---

## 3. Espaciado, tamaños y bordes: cuándo SÍ y cuándo NO usar dos capas

Después de colores y tipografía, tocaba `spacing.css`, `sizes.css` y `borders.css`. La tentación natural era copiar el mismo patrón de dos capas (primitivo → token semántico) en los tres, "porque así se hizo en los anteriores". La lección principal de esta sesión fue **cuestionar esa copia automática** y entender que el patrón de dos capas no es gratis: solo aporta valor bajo ciertas condiciones.

### 3.1 La regla que dedujiste

> Un token semántico (segunda capa) solo aporta valor cuando:
> **(a)** el valor pertenece a una **escala genérica reutilizable** — el mismo número podría aplicarse a propiedades o elementos completamente distintos sin que pierda sentido (como el spacing 4/8pt, o los colores de marca), **o**
> **(b)** el mismo valor concreto se repite entre **componentes/archivos que no se conocen entre sí**, y quieres un único lugar para cambiarlo.
>
> Si el valor nace siendo **específico de un solo elemento** del diseño (una medida que mediste directamente de la imagen y que no representa ningún concepto reutilizable), agregar una capa de primitivo + token es pura ceremonia — YAGNI (acrónimo del inglés "You Aren't Gonna Need It", traducible como "No lo vas a necesitar").

### 3.2 Cómo se aplicó a cada archivo

**`spacing.css` — se quedó con solo primitivos, sin capa semántica:**

```css
:root {
    --spacing-0: 0;
    --spacing-4: 4px;
    --spacing-8: 8px;
    --spacing-12: 12px;
    --spacing-16: 16px;
    --spacing-24: 24px;
    --spacing-32: 32px;
    --spacing-40: 40px;
    --spacing-48: 48px;
}
```

Es una escala de 4/8 puntos (cada valor es múltiplo de 4) — una práctica real y muy usada porque da consistencia visual: todo el espaciado del sitio "habla el mismo idioma" en vez de tener números sueltos (`13px`, `22px`...) que el ojo percibe como desalineados sin saber por qué.

Cumple la condición (a) — es una escala genérica — pero al revisar el diseño de esta card en particular, **no se encontró un caso real de la condición (b)**: cada espacio (padding interno de la card, gap entre ícono/título/párrafo/botón) se usa una sola vez, dentro de una única clase `.card`. No hay repetición entre archivos/componentes desconectados que justifique nombrar `--spacing-card-padding`, etc. Por eso: primitivos sueltos, consumidos directo en la clase `.card` cuando se escriba (`padding: var(--spacing-24)`).

**`sizes.css` — se simplificó, sin primitivo intermedio:**

Los valores originales (`--size-343: 343px` para el ancho de la card, `--size-1049: 1049px` para el contenedor) **no cumplen ni (a) ni (b)**: no son parte de una escala reutilizable (no hay "escala de anchos" detrás, cada número es único a su propósito) y no se repiten en otro lado. Conclusión: se saltó el primitivo y se va directo a un nombre semántico (ej. `--size-card`, `--size-container`) con el valor real dentro — el primitivo intermedio no aportaba nada, solo un paso extra para escribir lo mismo dos veces.

**`borders.css` — misma conclusión, sin dos capas:**

```css
:root {
    --border-0: 0;
    --radius-8: 8px;
}
```

Se revisó si el radio de 8px se repetía en más de un elemento del diseño (candidato a escala reutilizable) — no fue el caso en esta card, así que tampoco se justificó separar primitivo/token aquí. Pendiente además: confirmar si `--border-0` realmente se va a usar en algún selector antes de dejarlo — una variable definida "por si acaso" y nunca consumida es otro síntoma de YAGNI.

### 3.3 Comparación rápida: ¿por qué colores y tipografía SÍ necesitaron dos capas y esto no?

| Archivo | ¿Escala reutilizable? | ¿Se repite entre componentes desconectados? | ¿Necesita dos capas? |
|---|---|---|---|
| `colors.css` | Sí (paleta de marca) | Sí (mismo color en bg y en texto de distintos elementos) | Sí |
| `typography.css` | Sí (familia/peso/tamaño reutilizados en título vs párrafo) | Sí | Sí |
| `spacing.css` (este proyecto) | Sí, pero sin caso real de reutilización cruzada todavía | No (por ahora) | No — solo primitivos |
| `sizes.css` | No (medidas puntuales de un solo elemento) | No | No — nombre semántico directo, sin primitivo |
| `borders.css` (este proyecto) | No (un solo radio, un solo uso) | No | No |

**Idea para llevarte:** la estructura del archivo (una capa o dos) es una **decisión de diseño basada en evidencia real del proyecto**, no una plantilla que se copia porque "los demás archivos de settings la tienen". Revisa el diseño primero, decide después.

---

## 4. ITCSS (Inverted Triangle CSS)

La idea: organizar el CSS por **capas de especificidad creciente**, de lo más genérico/global a lo más específico, para evitar guerras de especificidad y `!important`.

Tu carpeta `assets/styles/` ya sigue esta estructura casi de libro:

```
01-settings/   → variables: colores, tipografía, espaciado (NO generan CSS visible)
02-tools/      → mixins/funciones (si usaras Sass) — nada visible tampoco
03-generic/    → reset, normalize, box-sizing (afecta a TODO el documento)
04-elements/   → estilos por etiqueta HTML sin clases: h1, p, a, button
05-objects/    → patrones de layout reutilizables sin diseño visual (grids, wrappers)
06-atoms/      \
07-molecules/   } → aquí se mezcla con Atomic Design (ver sección 5)
08-organisms/  /
09-utilities/  → clases de una sola responsabilidad, máxima especificidad (.u-hidden, .mt-0)
```

**Regla mental clave de ITCSS:** conforme bajas en la lista, el CSS se vuelve **más específico y más explícito**, y afecta a **menos elementos**. `01-settings` puede "afectar" a todo el sitio (son solo variables), pero `09-utilities` debería afectar solo a un elemento puntual donde se aplique la clase.

`styles.css` es el punto de entrada que importa todo en el orden correcto — **el orden de los `@import` no es decorativo, es la implementación misma del principio ITCSS**:

```css
@import "./01-settings/settings.css";
@import "./02-tools/tools.css";
@import "./03-generic/generic.css";
@import "./04-elements/elements.css";
@import "./05-objects/objects.css";
@import "./06-atoms/atoms.css";
@import "./07-molecules/molecules.css";
@import "./08-organisms/organisms.css";
@import "./09-utilities/utilities.css";
```

**Pregunta para repasar:** si escribes un estilo para `button { }` (sin clase), ¿en qué carpeta debería vivir? ¿Y si es `.btn-primary { }`?

---

## 5. Atomic Design (dentro de ITCSS)

Atomic Design organiza los **componentes de UI** por nivel de composición, no por especificidad CSS. En este proyecto se combina con ITCSS ocupando las carpetas 06-08:

- **Átomos (`06-atoms`)**: la pieza más pequeña con sentido propio — un botón, un icono, un título suelto. No se puede "romper" en algo más chico sin perder su función.
- **Moléculas (`07-molecules`)**: un grupo pequeño de átomos que trabajan juntos con un propósito, formando una unidad reutilizable — por ejemplo, icono + título + párrafo + botón dentro de una misma tarjeta.
- **Organismos (`08-organisms`)**: secciones identificables y específicas del diseño, compuestas de moléculas y átomos, que le dan **identidad visual concreta** a esa parte de la interfaz — por ejemplo, un `header` con logo + navegación, o un `footer`.

### 5.1 El criterio real para distinguir molécula de organismo: repetición dentro de LA MISMA página

La definición de libro ("molécula = grupo de átomos", "organismo = grupo de moléculas") no basta para decidir en la práctica. La pregunta que sí funciona:

> **¿Cuántas veces aparece este patrón dentro de UNA SOLA vista/página?**
> - Se repite varias veces en la misma página (y podría reutilizarse incluso en otro proyecto porque no depende del contexto) → **átomo o molécula**.
> - Aparece **una sola vez por página**, aunque el mismo diseño se repita de página en página del mismo sitio (como el header) → **organismo**.

**Ejemplo corregido de este proyecto** (la primera versión de este apunte decía lo contrario — quedaba mal): la tarjeta completa (icono + título + párrafo + botón) se repite **3 veces en la misma página** (Sedans, SUVs, Luxury) → es una **molécula** (`card`), no un organismo. Las variantes de color/icono por tarjeta se manejan con un **modificador BEM** (`card--sedans`, `card--suvs`, `card--luxury`), no con clases nuevas por completo.

Un `header` con logo + navegación, en cambio, sí sería un organismo: aparece una sola vez por página, aunque se repita en todas las páginas del sitio.

**Cómo se relaciona con tu `index.html` actual:**

```html
<article class="">
  <div class="">icon</div>      <!-- átomo -->
  <div class="">Sedans</div>    <!-- átomo -->
  <div class="">...</div>       <!-- átomo -->
  <div class="">button</div>    <!-- átomo -->
</article>
```

Cada `<div>` suelto es un átomo. El `<article>` completo (icono + título + párrafo + botón juntos) es la **molécula** `card`, con un modificador BEM por variante.

**Pregunta para repasar:** si en otro proyecto tuvieras una **lista de 20 comentarios**, cada uno con avatar + nombre + texto — ¿ese "comentario" sería átomo, molécula u organismo? ¿Y la sección completa que envuelve los 20 comentarios?

---

## 6. OOCSS (Object-Oriented CSS)

Dos principios que ya estás aplicando sin llamarlos así:

1. **Separar estructura de skin (apariencia).** Estructura = tamaño, layout, posición. Skin = colores, tipografía, bordes. Tus tokens de color y tipografía son precisamente la capa de "skin" separada de la capa de "estructura" (espaciado/layout en `spacing.css` y los objetos de `05-objects`).
2. **Separar contenedor de contenido.** Un componente no debería asumir *dónde* vive. Por ejemplo, la tarjeta de "Sedans" debería verse igual sin importar si está dentro de un `<article>` o de un `<section>` — su estilo no depende de su padre.

**Cómo se ve en la práctica en este proyecto:** en vez de escribir `.card-sedans { background: #e38826; padding: 32px; font-family: ... }` todo junto y repetido tres veces (una por color de tarjeta), separas:
- La **estructura común** (tamaño, padding, layout) en una clase compartida tipo `.card` (objeto reutilizable).
- El **skin variable** (el color de fondo/texto de cada tarjeta) en un modificador tipo `.card--sedans`, que solo cambia los tokens de color.

Esto evita repetir reglas de layout tres veces y hace que agregar una cuarta tarjeta sea trivial.

### 6.1 Ejemplo concreto: el objeto "wrapper" (centrado responsivo)

Un patrón de estructura pura que detectaste directamente en el diseño: los elementos están centrados tanto en móvil como en desktop, sin importar qué contenido lleven dentro. Candidato perfecto para `05-objects`:

- **`max-width`**: limita el ancho en pantallas grandes, pero permite encogerse en pantallas chicas (a diferencia de un `width` fijo, que se rompería en móvil).
- **`margin: auto`**: reparte el espacio sobrante en partes iguales a los lados, centrando el elemento sin cálculos manuales.

Esta combinación no lleva ni color ni tipografía — es 100% estructura. Por eso vive en `objects` y se puede reutilizar en cualquier contenedor del sitio (header, secciones, footer...), a diferencia de usar `display: flex; justify-content: center`, que tiene más sentido cuando lo que quieres centrar es un grupo de *varios hijos*, no un único contenedor centrándose a sí mismo.

### 6.2 Un mismo elemento puede llevar VARIAS clases a la vez

La duda más común al combinar OOCSS con Atomic Design es: *"¿esta clase va en `objects` o en `organisms`?"* — la respuesta muchas veces es **ambas, como clases separadas en el mismo elemento**, en vez de forzar una sola clase que lo haga todo.

**Ejemplo de este proyecto:** el contenedor que agrupa las 3 tarjetas necesita:
- Estructura reutilizable (`max-width` + centrado) → clase de **objeto** (el mismo wrapper de 6.1).
- Identidad visual específica de esta sección (borde redondeado, etc.) → clase de **organismo** (ej. `cards-container`).

En el HTML, el elemento lleva las dos clases juntas: una resuelve "cómo se acomoda", la otra resuelve "cómo se ve". Cada clase tiene una sola responsabilidad — ese es el corazón de OOCSS, y la pieza que hace que ITCSS + OOCSS + Atomic Design encajen sin pelearse entre sí.

**Pregunta para repasar:** si mañana necesitas centrar y limitar el ancho de una sección de "testimonios" en otro proyecto, ¿reutilizarías la misma clase de objeto wrapper, o crearías una nueva? ¿Por qué?

---

## 7. Cómo se conecta todo

```
OOCSS (principio) ──► te dice CÓMO escribir cada regla (separar estructura de skin)
Atomic Design      ──► te dice CÓMO llamar/organizar los componentes (átomo/molécula/organismo)
ITCSS               ──► te dice DÓNDE poner el archivo según su nivel de especificidad
Design tokens        ──► te dan el VOCABULARIO reutilizable (colores, fuentes, espaciados)
```

No son alternativas entre sí — se usan **a la vez**, cada una resolviendo un problema distinto (organización de carpetas vs. nomenclatura de componentes vs. estilo de las reglas vs. valores reutilizables).

---

## 8. Checklist rápido para el próximo proyecto

- [ ] ¿Definí primero los primitivos de color/tipografía/espaciado antes de escribir cualquier componente?
- [ ] ¿Los tokens semánticos describen el *uso* (`--color-bg-card`) y no el valor (`--color-orange`)?
- [ ] ¿El prefijo del token (`bg-`, `text-`, `border-`) coincide con la propiedad CSS real que va a recibir, verificado contra el diseño (no solo contra la descripción en texto)?
- [ ] ¿Decidí separar primitivos/tokens en archivos distintos por el tamaño real del proyecto (muchas líneas, difícil de escanear) y no "porque es lo que se hace"?
- [ ] ¿Cada archivo CSS vive en la capa ITCSS correcta según su especificidad?
- [ ] ¿Puedo identificar, para cada componente, si es átomo, molécula u organismo?
- [ ] Para decidir entre molécula y organismo, ¿revisé cuántas veces se repite el patrón DENTRO DE LA MISMA página (se repite → átomo/molécula; aparece una vez por vista → organismo)? — ver sección 5.1
- [ ] ¿Separé la estructura (layout/tamaño) del skin (color/tipografía) en clases distintas?
- [ ] Antes de escribir una sola clase que "hace de todo", ¿revisé si el elemento puede llevar varias clases a la vez (una de `objects` para estructura + una de `organisms`/`molecules` para skin)? — ver sección 6.2
- [ ] ¿Algún componente depende de dónde está colocado en el HTML (rompe OOCSS)?
- [ ] Si agregué un `@font-face`, ¿el archivo que lo contiene está realmente importado en la cadena que llega a `styles.css`?
- [ ] ¿Cada `@font-face` tiene `font-weight` correcto según el archivo `.ttf` usado, y `font-display: swap`?
- [ ] Si creé un archivo nuevo de settings (ej. `typography.css`, `spacing.css`), ¿ya lo agregué al `@import` de `settings.css`? Un archivo sin importar no da error, simplemente sus variables no existen para el resto del CSS.
- [ ] En cada par primitivo/token, ¿tienen nombres **distintos**? Un token semántico con el mismo nombre que su primitivo se auto-referencia y el navegador lo descarta en silencio (sin error visible) — ver sección 2.3.
- [ ] Antes de crear un archivo de settings con dos capas (primitivo + token), ¿verifiqué que el valor pertenece a una escala reutilizable O se repite entre componentes desconectados? Si no cumple ninguna de las dos, un nombre semántico directo (sin primitivo intermedio) es más simple y honesto — ver sección 3.
- [ ] ¿Definí alguna variable "por si acaso" que ningún selector usa todavía? Bórrala hasta que la necesites de verdad (YAGNI).

---

## 9. Elements vs. Generic vs. Modificador: cómo decidir dónde va cada regla

Al implementar capas reales (no solo definirlas en teoría), aparecen dudas prácticas que la definición de libro no resuelve. Estas son las preguntas que sí funcionan:

### 9.1 ¿Esto es "quitar opinión del navegador" o "poner mi propia opinión de diseño"?

- **`03-generic`**: deshacer el comportamiento por defecto feo del navegador (márgenes raros, bordes de formularios, etc.), **sin decidir nada de tu diseño todavía**. Ejemplo de patrón: poner `margin: 0` a etiquetas que el navegador rellena con espacio propio por defecto.
- **`04-elements`**: ahí SÍ decides cómo se ve esa etiqueta según TU sistema de diseño (tipografía, tamaños, colores que no varían).

Pista para no confundirlas: si la regla sería igual de válida en cualquier proyecto del mundo (sin importar el diseño), va en `generic`. Si depende de las decisiones visuales de ESTE proyecto (tus tokens de tipografía/color), va en `elements` o más abajo.

### 9.2 ¿Esta propiedad varía entre instancias del mismo componente, o es siempre igual?

Antes de decidir si una propiedad va en la etiqueta base (`elements`) o en un modificador de componente:

> Revisa TODAS las veces que se usa esa etiqueta/componente en el diseño. ¿El valor de esa propiedad específica es idéntico en todos los casos, o cambia según el contexto?
> - **Idéntico siempre** → puede vivir en la etiqueta base (`elements`) o en la clase base del componente (sin modificador).
> - **Cambia según el contexto/variante** → va en un modificador (BEM `--variante`), no en la base.

Ejemplo de patrón (nombres genéricos): si el peso de fuente de un `h2` es el mismo en las 5 tarjetas de tu diseño, ponlo en `h2 { font-weight: ... }`. Si el color de fondo cambia en cada tarjeta, ese va en `.card--variante-a`, no en `.card` ni en `h2`.

### 9.3 No le temas a poner un "default" en `elements` por miedo a que no sirva en el futuro

Duda común: *"si defino el estilo de `h2` ahora, ¿no se verán afectados otros `h2` que en el futuro necesiten verse distinto?"*

La respuesta está en cómo funciona la cascada: **un selector de clase siempre gana sobre un selector de etiqueta sola**, sin importar en qué capa/orden esté. Si mañana necesitas un `h2` distinto en otro contexto, escribes una clase más específica en una capa posterior (`molecules`/`organisms`) y esa clase gana automáticamente. No necesitas dejar la etiqueta base "vacía por si acaso" — la flexibilidad para casos especiales ya está garantizada por el propio diseño de ITCSS.

### 9.4 El orden de `@import` no es el orden en que tienes que escribir el código

El orden de las capas en `styles.css` define el orden de importación/especificidad — no te obliga a terminar el 100% de una capa antes de tocar la siguiente. En proyectos grandes, muchos equipos avanzan "por componente" (tocan varias capas a la vez para una sola pieza del diseño). Ir capa por capa (como hiciste tú) es una forma válida y útil de aprender, porque te obliga a pensar una sola responsabilidad a la vez — pero no es una regla obligatoria para siempre.

---

## 10. Tokens: matices que se te escaparon la primera vez

Complementa lo ya explicado en la sección 1-3 con estos casos reales que aparecieron al escribir código de verdad:

### 10.1 El tipo de selector (etiqueta vs. clase) NO cambia la regla

Da igual si estás escribiendo `body { }`, `h2 { }` o `.card { }` — la regla sigue siendo la misma: **usa el token semántico, nunca el primitivo directo**, fuera de la capa `settings`. Es un error común pensar "como esto es una etiqueta genérica y no una clase específica, aquí sí puedo usar el valor crudo" — no hay tal excepción.

### 10.2 Antes de crear un token nuevo "por si acaso", revisa dos cosas

1. **¿La propiedad ya se hereda de un ancestro?** Varias propiedades CSS (`color`, `font-family`, `font-weight`, `font-size`, `letter-spacing`, entre otras) se heredan del padre al hijo automáticamente. Si ya definiste el token en un elemento padre, probablemente no necesitas repetirlo ni crear una variante para el hijo — a menos que el hijo YA necesite verse distinto *hoy*.
2. **¿Ya existe un token con el rol que necesitas?** Antes de inventar uno nuevo, busca en tu archivo de settings si ya hay un token pensado exactamente para ese propósito.

Crear un token nuevo "por si en el futuro cambia" es la misma trampa de YAGNI que ya identificaste en la sección 3 — solo créalo cuando la necesidad de que diverja ya es real, no hipotética.

### 10.3 Dos tokens con el mismo valor HOY no son intercambiables

Si dos tokens distintos apuntan al mismo primitivo (por ejemplo, el color de fondo de un componente y el color de texto de otro elemento relacionado, que hoy coinciden en tono), **usa siempre el token que describe el ROL real de lo que estás estilizando**, no uno "prestado" de otro concepto solo porque hoy da el mismo resultado visual. Si mañana cambia uno de los dos valores, usar el token equivocado acopla dos decisiones de diseño que en realidad eran independientes, y el bug es silencioso (todo se ve bien... hasta que uno de los dos cambia y el otro se mueve con él sin que lo esperaras).

---

## 11. Nomenclatura y organización de componentes: lecciones al escribir BEM real

- **Extiende tus prefijos si hay ambigüedad.** Si ya usas `o-` para objetos (OOCSS) y necesitas un prefijo para organismos (Atomic Design), no reutilices la misma letra — inventa uno que no choque (por ejemplo, dos letras en vez de una). La meta es que cualquiera pueda adivinar la capa de un elemento con solo leer el nombre de la clase.
- **Si un modificador solo tiene sentido DENTRO de un componente específico, no lo pongas en la capa de átomos genérica.** Un átomo debe ser reutilizable en cualquier contexto sin depender de dónde vive. Si una variante de color/estilo de un átomo (como un botón) solo aplica cuando está dentro de un componente padre específico, esa relación pertenece a la capa del componente dueño (molécula/organismo), usando BEM completo: `.bloque__elemento--modificador`. Así el átomo se queda limpio y genérico, y la variante vive donde realmente pertenece.

---

## 12. Mecánica de Flexbox: errores que se repiten mucho

Estos son los "gotchas" de flexbox que más cuestan la primera vez — vale la pena memorizarlos porque se repiten en casi cualquier proyecto:

1. **`margin: auto` solo centra si el MISMO elemento tiene un límite de ancho** (`max-width` o `width`). Si el elemento ya ocupa el 100% de su contenedor, no hay "espacio sobrante" que repartir, y `margin: auto` no hace nada visible.

2. **Un elemento hijo de un contenedor `flex` NO llena el 100% del ancho disponible por defecto**, a diferencia de un bloque normal (`div`, `p`, etc. fuera de un flex). Por defecto, un ítem flex se ajusta al tamaño de su propio contenido — necesitas `flex-grow`, un `width` explícito, o `flex-basis` para que llene espacio.

3. **`border-radius` en un contenedor padre NO recorta a sus hijos automáticamente.** Si los hijos tienen esquinas cuadradas y llegan hasta el borde del padre, tapan visualmente el redondeo. Agrega `overflow: hidden` al padre para que sí recorte cualquier contenido que se salga de su forma.

4. **`min-height` (como `100vh`) solo genera espacio visible para centrar si el contenido real es MÁS CHICO que ese mínimo.** Si el contenido ya es más alto que el mínimo, no hay espacio sobrante para repartir — el mismo problema que el `margin: auto` sin límite de ancho, pero en el eje vertical. Para garantizar un espacio fijo sin importar cuánto contenido haya, un `padding` fijo es más confiable que depender de centrado dentro de un mínimo.

5. **`flex-grow` reparte proporcionalmente el espacio SOBRANTE entre los hermanos que también tienen `flex-grow` mayor a 0** — no es un tamaño fijo. Si un elemento es el ÚNICO de sus hermanos con `flex-grow` distinto de cero, el número exacto (1, 2, 10...) no importa — se lleva el 100% del sobrante de cualquier forma, porque no hay competencia. El número solo importa cuando dos o más hermanos compiten por el mismo espacio sobrante. Por convención, usa `flex-grow: 1` para el caso simple de "que este elemento absorba todo el espacio sobrante", y reserva otros números para cuando sí hay competencia real entre varios elementos.

6. **Por defecto, los ítems de un contenedor `flex` en fila ya tienen la misma altura entre sí** (`align-items: stretch` es el valor inicial), sin que tengas que definirlo tú. Útil para que varias tarjetas/columnas queden parejas en altura sin código extra.

---

## 13. Accesibilidad: árbol de decisión rápido (no reglas fijas)

### 13.1 ¿Cuándo usar `<h1>`?

- Un `<h1>` representa el tema principal de **toda la página** — normalmente uno solo por página.
- Contenido que se repite varias veces en la misma vista (tarjetas, tarjetas de producto, comentarios...) usa un nivel más abajo (`h2`, `h3`), no `h1` repetido.
- Si estás construyendo un **componente aislado** (no una página completa), puede que no haya ningún título de página que amerite un `h1` — es una decisión de contexto, no una regla que se cumple siempre a ciegas.

### 13.2 Árbol de decisión para `alt` en imágenes

1. **¿La imagen es la ÚNICA fuente de esa información** (no hay texto cerca que diga lo mismo)? → `alt` descriptivo real.
2. **¿La imagen ES el control interactivo** (un botón/link que solo tiene un ícono, sin texto visible)? → el `alt` describe la ACCIÓN o el destino, no el aspecto visual del ícono.
3. **¿La imagen refuerza visualmente algo que el texto de al lado ya dice igual de bien?** → `alt=""` (vacío, pero el atributo debe seguir presente — quitarlo por completo hace que algunos lectores de pantalla lean el nombre del archivo en su lugar).
4. Nunca pongas la palabra "imagen"/"ícono" dentro del propio `alt` — los lectores de pantalla ya anuncian por su cuenta que es una imagen.

### 13.3 Un elemento sin CSS no es un elemento innecesario

Etiquetas semánticas como `<main>`, `<nav>`, `<header>`, `<footer>` aportan valor de accesibilidad (navegación por "landmarks" para quien usa lector de pantalla) y de SEO, **incluso si no llevan ninguna clase ni estilo visual**. La utilidad visual y la utilidad semántica son ejes distintos — no asumas que "no tiene estilos" significa "no sirve de nada".

---

## 14. Metodología de depuración que ya usaste (y te sirvió)

1. **Aísla una variable a la vez.** Cuando algo no se ve como esperabas, no cambies varias cosas al mismo tiempo — comenta o quita UNA propiedad/clase específica, recarga, y observa si el resultado cambia. Así sabes con certeza qué es lo que realmente está causando el efecto, en vez de asumir.
2. **No confundas correlación con causalidad.** Que algo "se vea bien" después de un cambio no prueba que ESE cambio fue el responsable — puede que otra regla ya estuviera resolviendo el problema. Prueba quitando el cambio sospechoso y verifica si el resultado se mantiene igual.
3. **Una vez confirmado que un mecanismo es redundante, bórralo.** Si dos reglas/clases distintas están logrando el mismo efecto visual, quédate con una sola (la más simple/clara) y elimina la otra — mismo principio de YAGNI aplicado a clases CSS, no solo a variables.

---

## 15. Recursos para profundizar

- ITCSS (charla original de Harry Roberts): buscar "ITCSS Harry Roberts" en YouTube/CSS-Tricks.
- OOCSS: https://github.com/stubbornella/oocss/wiki
- Atomic Design (Brad Frost, libro gratuito online): https://atomicdesign.bradfrost.com/
- MDN — Variables CSS (custom properties): https://developer.mozilla.org/en-US/docs/Web/CSS/Using_CSS_custom_properties
- MDN — `@font-face`: https://developer.mozilla.org/en-US/docs/Web/CSS/@font-face
- MDN — `font-display`: https://developer.mozilla.org/en-US/docs/Web/CSS/@font-face/font-display
