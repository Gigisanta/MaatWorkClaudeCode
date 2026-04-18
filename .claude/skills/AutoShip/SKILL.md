---
name: autoship
description: Autonomous ship-it loop that takes a broken/incomplete app and drives it to production-ready using Playwright MCP for browser automation, subagents for fixes, and a 7-phase loop (Discovery → Baseline → Triage → Dispatch → Verify → Harden → Ship).
---

# AUTOSHIP — Autonomous Ship-It Loop (Playwright MCP edition)

> Tomás una app (rota, media-hecha, legacy, o supuestamente "lista") y no parás hasta que esté **vendible**.
> Main session = eyes + brain. Subagentes = manos. Loop = memoria.
> Browser automation vía **Playwright MCP** (`@playwright/mcp`).

---

## 🎯 MISIÓN

Llevar el repo abierto desde su estado actual hasta **PRODUCTION-READY** sin intervención humana. Si encontrás la app totalmente rota, la arreglás. Si está OK, la endurecés. No parás hasta que pasen **todas** las exit gates de §7.

**Vos sos el orchestrator.** No escribís fixes en esta sesión (salvo triviales <5 LOC). Para todo lo demás, disparás subagentes y seguís explorando mientras trabajan en paralelo.

---

## 🚀 START NOW (sin pedir permiso)

Arrancá en este orden, sin preguntar nada al usuario:

1. **Bootstrap del estado** (crea `.autoship/` si no existe, ver §3)
2. **Verificá que Playwright MCP esté conectado** — si no, instrucciones en §0
3. **F0 – Discovery** (reconocer el terreno, ver §4)
4. **F1 – Baseline** (medir dónde estamos parados, ver §4)
5. **Entrar al loop** (F2 → F5, ver §4)
6. **F6 – Ship gate** cuando el health score lo permita
7. **TERMINATE** sólo cuando cumplas §7 completo

Si en cualquier iteración se gatilla un circuit breaker (§6), pausá y pedí ayuda con un reporte estructurado.

---

## 0. PRE-FLIGHT — Playwright MCP

Antes de F0, confirmá que tenés los tools de Playwright MCP disponibles. Deberías ver tools con prefijo `browser_*` (snapshot, navigate, click, etc).

Si **no** están disponibles, instruí al usuario a correr:
```
claude mcp add playwright npx @playwright/mcp@latest
```
Y pausá hasta que confirme. No sigas sin el browser.

Si la app necesita browser con cookies reales / sesión del usuario, mencionalo — Playwright MCP corre con profile ephemeral por default; se puede usar `--user-data-dir` o la extensión oficial si hace falta auth persistente.

---

## 1. FILOSOFÍA (no la rompas)

- **Tests = verdad.** Una tarea no está hecha porque "parece andar". Está hecha cuando el test + el browser check lo confirman.
- **Commits como checkpoints.** Un fix = un commit. Si algo se rompe, `git revert` te salva.
- **Fresh context para fixes.** Los subagentes arrancan limpios. Vos mantenés el overview.
- **Evidence > opinion.** Screenshots, snapshots de accesibilidad, console logs, network logs. Sin evidencia, no es fix.
- **Accessibility snapshot > screenshot.** El snapshot de Playwright es estructurado, determinista y liviano en tokens. Usá screenshots sólo para evidencia visual.
- **Fail predictably.** Si un approach no funciona en 3 intentos, cambiá la estrategia, no insistas.
- **Ship mentality.** "Production-ready" no es "corre en mi máquina". Ver §7.

---

## 2. TU ROL

```
MAIN SESSION (vos):
  ✅ Explorar con Playwright MCP (snapshot-driven)
  ✅ Clasificar bugs por severidad
  ✅ Dispatch de subagentes (paralelo cuando dominios son independientes)
  ✅ Actualizar .autoship/status.json
  ✅ Verificar fixes con browser_navigate + browser_snapshot + browser_console_messages
  ✅ Decidir cuándo la app está lista
  ✅ Git commits de milestones

  ❌ NO implementás fixes acá (excepto typos <5 LOC)
  ❌ NO investigás root cause a fondo acá (delegás)
  ❌ NO dejás que el context se llene con dumps de archivos
  ❌ NO abusás de browser_take_screenshot — prefiere browser_snapshot para interactuar
```

---

## 3. ESTADO PERSISTENTE (`.autoship/`)

Crealo en la primera iteración. Todo va acá para que el loop sobreviva al reinicio del context.

```
.autoship/
├── status.json         ← single source of truth, ver schema abajo
├── bugs.jsonl          ← un bug por línea, append-only
├── fixes.jsonl         ← un fix aplicado por línea, append-only
├── iterations.log      ← log humano-leíble de cada iteración
├── baseline/           ← snapshots + screenshots + perf metrics + red de la app al arrancar
├── evidence/           ← screenshots + snapshots de cada verify
└── AGENTS.md           ← aprendizajes de iteraciones previas (auto-mantenido)
```

### `status.json` schema

```json
{
  "iteration": 0,
  "phase": "F0_DISCOVERY | F1_BASELINE | F2_TRIAGE | F3_DISPATCH | F4_VERIFY | F5_HARDEN | F6_SHIP",
  "health_score": 0,
  "bugs_open": { "p0": 0, "p1": 0, "p2": 0, "p3": 0 },
  "bugs_closed": { "p0": 0, "p1": 0, "p2": 0, "p3": 0 },
  "tests": { "total": 0, "passing": 0, "failing": 0, "skipped": 0, "coverage_pct": null },
  "routes_explored": [],
  "routes_total": null,
  "perf": { "lcp_ms": null, "inp_ms": null, "cls": null, "ttfb_ms": null },
  "last_commit": "",
  "circuit_breaker": { "tripped": false, "reason": "" },
  "subagents_active": [],
  "started_at": "ISO-8601",
  "updated_at": "ISO-8601",
  "exit_ready": false
}
```

Lo **primero** de cada iteración: `read .autoship/status.json`.
Lo **último** de cada iteración: `update .autoship/status.json` + `append .autoship/iterations.log`.

---

## 4. LAS 7 FASES

### F0 · DISCOVERY (una sola vez al inicio)

Antes de tocar nada, entendé el terreno. En paralelo (dispatch 3 subagents):

- **Recon-Code** → lee `README.md`, `package.json`/`pyproject.toml`/etc, `AGENTS.md`/`CLAUDE.md` si existen, detecta stack (frameworks, DB, auth, deploy target), lista scripts disponibles (`build`, `dev`, `test`, `lint`, `typecheck`).
- **Recon-Routes** → mapea estructura de rutas/endpoints leyendo código (no browser todavía).
- **Recon-Tests** → inventaría qué tests existen, cuál es el runner, si hay E2E/unit/integration. Detectá si ya hay Playwright tests en el repo (`playwright.config.ts`, carpeta `e2e/` o `tests/`).

Con los reportes, escribí en `.autoship/AGENTS.md`:
- Stack detectado
- Comando para levantar la app en dev
- Comando para correr tests
- Comando para typecheck/lint
- Rutas conocidas
- URL base de dev (ej: `http://localhost:3000`)
- Credenciales de test si existen (en `.env.example` o README)
- Sospechas iniciales (archivos con TODO, FIXME, HACK, código comentado grande)

### F1 · BASELINE (una sola vez)

Con la app corriendo, medí el piso:

1. `browser_navigate(url=homepage)` → esperá load con `browser_wait_for(text="...")`
2. `browser_snapshot()` → guardá el accessibility tree en `baseline/home.snapshot.txt`
3. `browser_take_screenshot(filename="baseline/home.png")` → evidencia visual
4. `browser_console_messages()` → guardá en `baseline/home.console.json`
5. `browser_network_requests()` → guardá en `baseline/home.network.json`, flaggeá 4xx/5xx
6. Core Web Vitals via `browser_evaluate` (ver §Appendix F) → `baseline/perf.json`
7. Corré la suite de tests completa. Guardá output en `baseline/tests.txt`.
8. Corré typecheck + lint. Guardá en `baseline/static.txt`.
9. Calculá **health_score inicial** (§5) y escribilo en status.json.

**No arregles nada en F1.** Sólo medí.

### F2 · TRIAGE (por iteración)

Exploración sistemática. Una ruta por iteración (o un flow completo si es corto).

Por cada ruta:
```
□ browser_navigate(url)
□ browser_wait_for(text="<contenido esperado>") — no te confíes del load event
□ browser_snapshot() → guardá para sacar refs de elementos
□ browser_console_messages() → errores/warnings = bug
□ browser_network_requests() → status ≠ 2xx/3xx = bug
□ Estados: loading, empty, error, success → provocá cada uno
□ Forms: browser_fill_form con casos (vacío, inválido, válido, XSS, unicode, SQL-like)
□ Botones/links: browser_click por cada CTA visible (usando ref del snapshot)
□ Modales: abrir → cerrar (X, click fuera, ESC via browser_press_key)
□ Responsive: browser_resize(375,667) + browser_resize(1440,900) → snapshot cada uno
□ Auth-gated: probar acceso sin auth (¿redirige o filtra?)
□ Pestañas/tabs: browser_tabs si la app tiene multi-tab flow
```

**Sintaxis clave de Playwright MCP:**
```
# Click requiere ref (del snapshot) + element (descripción humana)
browser_click(element="Submit button", ref="e42")

# Type también necesita ref + element
browser_type(element="Email input", ref="e12", text="test@example.com")

# fill_form es más eficiente para múltiples campos
browser_fill_form(fields=[
  {element="Email", ref="e12", value="test@example.com"},
  {element="Password", ref="e13", value="..."}
])
```

Cada anomalía → `bugs.jsonl` + clasificá severidad (§6). Los P0/P1 van al dispatch. P2/P3 quedan en cola.

### F3 · DISPATCH (la potencia del loop)

Mandás subagentes en paralelo cuando los dominios son **independientes**. En serie cuando hay dependencia.

**Reglas de paralelismo:**
- ✅ Paralelo: Frontend bug + Backend bug + DB migration + Doc fix (archivos disjuntos)
- ✅ Paralelo: 3 fixes en componentes distintos
- ❌ Serie: 2 fixes que tocan el mismo archivo
- ❌ Serie: Fix B depende del fix A (schema → query → UI)

Límite recomendado: **max 4 subagents concurrentes** para no saturar el context ni el rate limit. Si tenés más bugs, procesá en batches.

**IMPORTANTE:** Playwright MCP tiene **1 browser context compartido**. Los subagents que hagan browser work van en serie salvo que abras tabs con `browser_tabs(action="new")`. Para fixes de código puro que no necesitan browser, paralelismo full.

Mientras los subagentes trabajan, vos seguís con F2 en otras rutas (sin tocar browser si alguno lo está usando).

### F4 · VERIFY

Cuando un subagent reporta ✅ FIXED:

1. `git log -1` → confirmá que hay commit del fix
2. Si modificó código de UI/frontend →
   - `browser_navigate(ruta_afectada)`
   - `browser_wait_for(text="...")`
   - `browser_snapshot()` → comparar con snapshot previo
   - `browser_console_messages()` → debe estar limpia para el flow del fix
3. Si modificó tests → corré esa suite específica
4. Si tocó API → hitéala con `browser_evaluate(function="() => fetch('/api/...').then(r => r.json())")` o bash/curl
5. **Regression check**: corré suite completa de tests. Si algo rompió, reabrí el bug como P1 con tag `regression`.
6. `browser_take_screenshot(filename="evidence/bug_<id>_after.png")`
7. Actualizá `bugs.jsonl` con `status: closed` + commit hash

Si el fix no verifica, reabrí con nota "claimed fixed but <evidencia de que no>". Contador +1 en circuit breaker.

### F5 · HARDEN (cuando P0/P1 = 0)

Acá la app "anda". Ahora la pulís para vender.

Pasadas obligatorias:
- **Perf sweep**: Core Web Vitals en todas las rutas main (ver §Appendix F). Budget: LCP ≤2.5s, INP ≤200ms, CLS ≤0.1.
- **A11y sweep**: WCAG 2.1 AA básico → contraste, keyboard nav (`browser_press_key("Tab")`), alt text, aria labels, focus order. El snapshot de Playwright ya te da el accessibility tree — usá eso para detectar elementos sin role/label.
- **Security sweep** (§ Appendix C): tokens en console, XSS en inputs, rutas protegidas, CSP, headers.
- **Edge-case sweep**: errores de red (ver §Appendix G para simularlos), timeouts, 500s, payloads raros.
- **Empty/loading/error states**: toda ruta data-driven tiene los 3.
- **Copy polish**: typos, textos sin traducir, "Lorem ipsum", "TODO" visibles al usuario.
- **Responsive full matrix**: 375 / 768 / 1024 / 1440 / 1920 vía `browser_resize`. Sin overflow ni layout roto.

Cada issue de harden sigue el mismo ciclo dispatch → verify.

**BONUS — Codificar regresiones a E2E**: para cada bug P0/P1 cerrado, usá `browser_generate_playwright_test` para convertir la repro en un test `.spec.ts` permanente. Esto te deja un safety net para el futuro.

### F6 · SHIP GATE

Chequeo final (§7). Si pasa todo, TERMINATE con reporte.
Si falla, identificá el gap y volvé a F3.

---

## 5. HEALTH SCORE (0–100)

Sumá estas contribuciones cada iteración:

| Componente | Peso | Cómo |
|---|---|---|
| Suite de tests verde | 25 | `(passing / total) * 25` |
| Typecheck + lint limpio | 10 | 10 si clean, 5 si warnings, 0 si errors |
| Console limpia en rutas main | 15 | `15 * (1 - errors_ratio)` (via browser_console_messages) |
| Network sin fails (404/500) | 10 | `10 * (1 - fail_ratio)` (via browser_network_requests) |
| P0/P1 cerrados | 20 | `20 * (closed / (closed + open))` |
| Core Web Vitals dentro de budget | 10 | 10 si todas las rutas cumplen, prorrateado |
| Responsive sin overflow | 5 | 5 si todas las rutas x 3 breakpoints OK |
| A11y sin violations críticas | 5 | 5 si clean (desde accessibility snapshot) |

**Gates:**
- Score <40 → estás en rescate, foco 100% en P0/P1
- 40–70 → normal loop, F2+F3+F4
- 70–90 → entrar a F5 (harden)
- ≥90 y §7 pasa → F6 (ship)

---

## 6. SEVERIDAD Y CIRCUIT BREAKERS

### Severidad

| | Significado | Acción |
|---|---|---|
| 🔴 **P0** | App no arranca, flow crítico roto, data loss, security hole, secrets leaked | Dispatch inmediato, bloquea todo lo demás |
| 🟠 **P1** | Feature importante rota, error visible al usuario, test suite en rojo | Dispatch en este ciclo |
| 🟡 **P2** | Comportamiento incorrecto, UX degradada, warning en console | Dispatch si <15min, sino cola |
| 🟢 **P3** | Cosmético, perf no crítica, nice-to-have | Documentar, sólo se arregla en F5 |

### Circuit Breakers (pausá el loop si se gatillan)

1. **Same error 3x**: misma excepción/fail en 3 iteraciones seguidas → estrategia actual no funciona.
2. **Revert loop**: fix aplicado y revertido 2 veces → el problema es de diseño, no de código.
3. **Zero progress**: 5 iteraciones sin que baje P0+P1 → algo bloquea estructuralmente.
4. **Budget excedido**: >50 iteraciones totales → pedí ayuda, algo no cierra.
5. **Repo corrupt**: `git status` muestra cosas raras o tests del baseline empiezan a fallar → rollback al último commit verde.
6. **Auth/secrets faltan**: si el fix requiere credenciales que no tenés → pausá, no hardcodees nada.
7. **Browser stuck**: si `browser_snapshot` falla 2 veces seguidas o devuelve vacío → `browser_close` + `browser_navigate` fresh. Si persiste → pausá.

Cuando se gatilla: escribí un `PAUSE_REPORT.md` con qué pasó, qué intentaste, y qué input necesitás del humano. Después TERMINATE.

---

## 7. EXIT GATES — "VENDIBLE" (todos deben pasar)

No salís del loop hasta que **todos** digan sí:

### Funcional
- [ ] `npm test` (o equivalente) pasa 100% sin skips no justificados
- [ ] `npm run typecheck` limpio
- [ ] `npm run lint` limpio (o sólo warnings documentados)
- [ ] `npm run build` exitoso
- [ ] App arranca en dev con un solo comando
- [ ] Cero bugs P0 y P1 abiertos
- [ ] P2 abiertos ≤ 3 (documentados en `.autoship/known-issues.md`)

### UX/UI
- [ ] Toda ruta renderiza sin errores de console (verificado via `browser_console_messages`)
- [ ] Loading, empty, error states existen en rutas data-driven
- [ ] Responsive OK en 375 / 768 / 1440 sin overflow (verificado via `browser_resize`)
- [ ] Forms validan antes de enviar
- [ ] CTAs principales funcionan (login, signup, checkout, submit, etc según app)
- [ ] Sin "Lorem ipsum", "TODO", placeholders visibles al usuario

### Performance
- [ ] LCP ≤ 2.5s en homepage (medido via `browser_evaluate` con PerformanceObserver)
- [ ] INP ≤ 200ms en interacciones primarias
- [ ] CLS ≤ 0.1 en rutas main
- [ ] Bundle size no absurdo (flaggear si >1MB gzipped sin justificación)

### Seguridad
- [ ] Rutas protegidas redirigen a login si no hay auth
- [ ] No hay tokens/keys en console ni en bundle (check via `browser_console_messages`)
- [ ] Inputs resisten XSS básico (`<script>`, `"><img>`)
- [ ] CSP o headers de seguridad mínimos presentes si es app pública
- [ ] `.env` no committeado

### Deploy-readiness
- [ ] README explica cómo levantar dev y cómo deployar
- [ ] Variables de entorno documentadas en `.env.example`
- [ ] Build production corre y sirve correctamente
- [ ] Health check endpoint existe (si es backend)
- [ ] Errores se loguean estructuradamente (no sólo `console.log`)

### Evidencia
- [ ] Screenshots "after" en `evidence/` para cada ruta main
- [ ] Perf metrics finales guardados
- [ ] Playwright E2E tests generados para bugs P0/P1 cerrados
- [ ] `.autoship/SHIP_REPORT.md` generado con resumen de bugs cerrados, métricas, decisiones

---

## 8. TEMPLATE DE SUBAGENT

Usá este formato exacto para disparar cualquier fix:

```
Task("Repair Bug #[ID] – [título corto]"):

## Bug Description
[descripción precisa, no "hay algo raro"]

## Reproduction
- URL: [ruta donde ocurre]
- Steps: [1. browser_navigate(...) 2. browser_click(ref=...) 3. ...]
- Expected: [qué debería pasar]
- Actual: [qué pasa]

## Evidence
- Console: [mensajes exactos de browser_console_messages]
- Network: [request método + URL + status de browser_network_requests]
- Snapshot ref relevante: [ref del elemento problemático]
- Screenshot: evidence/bug_[ID]_before.png

## Constraints
- Root cause primero, fix después. No parches sobre síntomas.
- Si el fix requiere >3 archivos nuevos o cambios de schema, PARÁ y reportá "NEEDS_DESIGN"
- Tests existentes deben seguir pasando
- Agregá al menos 1 test que cubra este bug (regression test)
- Si es bug de UI interactivo, generá además un .spec.ts de Playwright con browser_generate_playwright_test
- Un solo commit, mensaje: "fix(scope): descripción [bug-ID]"

## Allowed scope
- Archivos: [lista, si sabés cuáles; si no, "investigá vos"]
- NO tocar: [paths off-limits si aplica, ej: migrations, auth config]

## Return format (pegalo exacto)
**Bug ID:** #[ID]
**Status:** ✅ FIXED | ⏳ PARTIAL | 🔴 BLOCKED | 🧩 NEEDS_DESIGN
**Root cause:** [1-2 frases]
**Fix:** [qué cambiaste]
**Files:** [lista con paths]
**Commit:** [hash]
**Tests added:** [nombres, incluí .spec.ts de Playwright si aplica]
**Verification:** [qué corriste para confirmar]
**Risk:** [qué podría haber roto, si algo]
```

---

## 9. REGLAS DURAS (no negociables)

1. **Nunca** modifiques `.env`, secrets, o credentials. Si faltan, `NEEDS_INPUT` → pausá.
2. **Nunca** hagas `git push --force` ni borres branches.
3. **Nunca** instales dependencias globales sin loguearlo en `AGENTS.md`.
4. **Siempre** commiteá antes de F5 para tener punto de rollback.
5. **Siempre** corré la suite de tests después de cada fix (no sólo el test del fix).
6. Si el bug requiere decisión de producto ("¿el botón va arriba o abajo?") → `NEEDS_DESIGN`, no inventes.
7. Si encontrás secrets o PII en el código/logs → pausá inmediato, reportá, no escribas en ningún log ni commit.
8. Jamás rompás un test existente para que "pase" el suite. Arreglá el código, no el test. Si el test está mal, documentá por qué y pedí confirmación.
9. **Nunca** dejes el browser abierto con estado contaminado entre iteraciones. Si una ruta corrompe el estado (ej: errores de auth), `browser_close` + navegación fresca.
10. **Nunca** uses `browser_evaluate` para correr código que mute estado persistente del servidor sin necesidad — es una puerta trasera peligrosa.

---

## 10. TERMINATION

### Salida exitosa
```
<promise>AUTOSHIP_COMPLETE</promise>

Iteraciones: [N]
Health score: [X]/100
Bugs cerrados: P0=[n] P1=[n] P2=[n] P3=[n]
Tests: [X/Y] passing, coverage [Z]%
E2E Playwright tests generados: [n]
LCP: [X]ms | INP: [X]ms | CLS: [X]
Commits: [N]
Tiempo: [elapsed]

Reporte completo: .autoship/SHIP_REPORT.md
Known issues (P2 aceptados): .autoship/known-issues.md
```

### Salida por circuit breaker
```
<promise>AUTOSHIP_PAUSED</promise>

Motivo: [breaker]
Iteración: [N]
Contexto: .autoship/PAUSE_REPORT.md

Input humano necesario: [qué necesito de vos]
```

---

## APPENDIX A — Playwright MCP tools

Lista oficial de tools (`@playwright/mcp@latest`):

```
# Navegación (4)
browser_navigate(url) · browser_navigate_back() · browser_navigate_forward() · browser_close()

# Inspección (4)
browser_snapshot()                    ← accessibility tree con refs (tu pan y manteca)
browser_take_screenshot(filename?)    ← evidencia visual
browser_console_messages()            ← errores/warnings/logs
browser_network_requests()            ← todas las requests con status

# Interacción (9)
browser_click(element, ref)
browser_type(element, ref, text, submit?)
browser_fill_form(fields[])           ← más eficiente para multi-input
browser_hover(element, ref)
browser_drag(startElement, startRef, endElement, endRef)
browser_select_option(element, ref, values)
browser_press_key(key)                ← Tab, Enter, Escape, ArrowDown, etc
browser_file_upload(paths)
browser_handle_dialog(accept, promptText?)

# Ejecución JS (1-2)
browser_evaluate(function)            ← corre JS en la página
browser_run_code(code)                ← corre Playwright code completo con acceso a page/context (si está habilitado)

# Sincronización (1)
browser_wait_for(text?, textGone?, time?)

# Viewport (1)
browser_resize(width, height)

# Tabs (1 agrupado en versiones nuevas, o 4 individuales en antiguas)
browser_tabs(action: list|new|select|close, index?)
# O bien: browser_tab_list · browser_tab_new · browser_tab_select · browser_tab_close

# Utilidades
browser_install()                     ← instala Chromium si falta
browser_generate_playwright_test()    ← genera .spec.ts del flow actual
browser_pdf_save(filename?)           ← guarda página como PDF
```

**Principio clave**: `browser_snapshot` devuelve algo como:
```
- button "Login" [ref=e23]
- textbox "Email" [ref=e24]
- link "Forgot password" [ref=e25]
```
Usá esos `ref` en `browser_click`, `browser_type`, etc. **Siempre pasá también `element`** como descripción humana — Playwright MCP lo requiere para seguridad y legibilidad.

⚠️ **No confundir con Chrome DevTools MCP** — aquel usaba `uid`, este usa `ref`. Aquel tenía `performance_start_trace` nativo, este **no** (ver Appendix F).

---

## APPENDIX B — Performance Budgets

| Métrica | Budget | Cómo medir |
|---|---|---|
| LCP | ≤2.5s | `browser_evaluate` con PerformanceObserver (§F) |
| INP | ≤200ms | `browser_evaluate` + interacción real |
| CLS | ≤0.1 | `browser_evaluate` con PerformanceObserver |
| TTFB | ≤800ms | `browser_network_requests` → primer request |
| Bundle JS (gzipped) | ≤500KB (warn >1MB) | build output o `browser_network_requests` sumando `.js` |
| Image sin optimizar | flaggear >200KB | `browser_network_requests` filtrado por tipo |
| 3rd-party requests | ≤15 en ruta main | `browser_network_requests` filtrado por dominio |

---

## APPENDIX C — Security Sweep

```
□ XSS básico: payload <script>alert(1)</script> via browser_type en cada input → sanitizado o escaped
□ Stored XSS: payloads en campos que se renderizan después (navegá + snapshot para confirmar escape)
□ Rutas protegidas sin auth → browser_navigate sin cookies → redirect a login, no 200 con data
□ Token en URL: inspeccioná response.url en browser_network_requests
□ Token en console: browser_console_messages después de login
□ Token en localStorage: browser_evaluate("() => Object.keys(localStorage)")
□ Secrets en bundle JS: browser_evaluate("() => document.querySelectorAll('script[src]').length") + inspección
□ CORS permissive (*) en APIs sensibles → headers en browser_network_requests
□ Headers de seguridad: CSP, X-Frame-Options, X-Content-Type-Options en response headers
□ .env en git log → P0 inmediato
□ Dependencias con CVEs (npm audit / pip-audit) → flag P1+ según severity
□ SQL injection patterns: ' OR 1=1 --, en inputs que tocan DB → sanitizado
□ Rate limit en endpoints de auth: repetir browser_click sobre Login 10x rápido → ¿429?
```

---

## APPENDIX D — Loop de trabajo típico (ejemplo concreto)

```
iter 1: F0 Discovery → 3 subagents recon → AGENTS.md escrito
iter 2: F1 Baseline → app levanta en localhost:3000
        browser_navigate + snapshot + console + network + perf
        12/40 tests pass, 3 console errors en home, LCP 4.8s
        health_score: 28 → rescate mode
iter 3: F2 Triage homepage → bug P0 (API /api/user → 500), bug P1 (CLS 0.34)
iter 4: F3 Dispatch 2 subagents paralelos (backend-fix + frontend-layout)
        Mientras: F2 en /login
iter 5: F4 Verify ambos:
          - browser_navigate(/), snapshot limpio, console sin errors → P0 cerrado ✓
          - browser_evaluate CLS → 0.05, dentro del budget → P1 cerrado ✓
          - 18/40 tests ahora
        F2 /login → bug P1 auth flow broken
iter 6: F3 Dispatch auth-fix. F2 /dashboard → 2 bugs P2
...
iter 18: health 72 → entrar F5
iter 19-30: F5 harden sweeps
          - Generá Playwright .spec.ts por cada bug cerrado con browser_generate_playwright_test
          - Perf sweep con browser_evaluate en todas las rutas main
          - Responsive matrix con browser_resize en 5 breakpoints
iter 31: F6 ship gate → todos los checks pasan → TERMINATE con <promise>AUTOSHIP_COMPLETE</promise>
```

---

## APPENDIX E — AGENTS.md (auto-mantenido)

Actualizá este archivo después de cada iteración con aprendizajes que sobrevivan al context reset:

```markdown
# AGENTS.md — aprendido por AUTOSHIP

## Stack
- Framework: [detectado]
- DB: [detectado]
- Auth: [detectado]
- Deploy: [detectado]

## URLs
- Dev: http://localhost:3000 (o lo que sea)
- Rutas principales: /, /login, /dashboard, ...

## Comandos
- Dev: `...`
- Test: `...`
- Test E2E (Playwright): `npx playwright test`
- Build: `...`
- Typecheck: `...`

## Credenciales de test (si aplica)
- [desde .env.example o README]

## Convenciones
- [ej: "los componentes van en src/components/, un archivo por componente"]
- [ej: "los tests son .test.ts al lado del archivo; E2E en e2e/*.spec.ts"]

## Gotchas descubiertos
- [ej: "el hot reload a veces pierde conexión WS, hay que recargar manual"]
- [ej: "Drizzle migrations necesitan DATABASE_URL seteado en runtime"]
- [ej: "browser_click sobre <SubmitButton custom> a veces fallaba — usar browser_press_key('Enter') en el form"]

## Decisiones tomadas
- [ej: "mantuve Redux aunque estaba a medio migrar a Zustand, porque tocar esto abre 15 bugs P2 colaterales"]
```

---

## APPENDIX F — Core Web Vitals con Playwright MCP

Playwright MCP **no** tiene `performance_start_trace` como Chrome DevTools MCP. Medí con `browser_evaluate` + PerformanceObserver. Snippet reutilizable:

```javascript
// Usar con: browser_evaluate(function=<este código>)
() => new Promise((resolve) => {
  const metrics = { lcp: null, cls: 0, fcp: null, ttfb: null };

  // TTFB
  const nav = performance.getEntriesByType('navigation')[0];
  if (nav) metrics.ttfb = nav.responseStart - nav.requestStart;

  // FCP
  const fcpEntry = performance.getEntriesByName('first-contentful-paint')[0];
  if (fcpEntry) metrics.fcp = fcpEntry.startTime;

  // LCP — observá la última entry
  new PerformanceObserver((list) => {
    const entries = list.getEntries();
    metrics.lcp = entries[entries.length - 1].startTime;
  }).observe({ type: 'largest-contentful-paint', buffered: true });

  // CLS acumulado
  new PerformanceObserver((list) => {
    for (const entry of list.getEntries()) {
      if (!entry.hadRecentInput) metrics.cls += entry.value;
    }
  }).observe({ type: 'layout-shift', buffered: true });

  setTimeout(() => resolve(metrics), 3000);
})
```

Para **INP** necesitás interacción real. Flow:
1. `browser_navigate(ruta)`
2. Instalá listener con `browser_evaluate` que loguee `event.processingEnd - event.startTime` del Event Timing API
3. `browser_click` o `browser_type` sobre el CTA primario
4. `browser_evaluate` para recuperar la métrica

Alternativa más robusta: pediles a los subagents que instalen `web-vitals` npm package y lo expongan en `window.__vitals` durante dev, así el monitoreo es declarativo.

---

## APPENDIX G — Edge cases de red sin throttling nativo

Playwright MCP **no** tiene `emulate_network(preset: slow3g)` como Chrome DevTools MCP. Alternativas:

**Opción 1: route mocking via `browser_run_code`** (si está habilitado):
```javascript
async ({ context }) => {
  await context.route('**/api/**', async route => {
    await new Promise(r => setTimeout(r, 3000)); // delay 3s
    await route.continue();
  });
}
```

**Opción 2: forzar 500 en un endpoint específico:**
```javascript
async ({ context }) => {
  await context.route('**/api/user', route =>
    route.fulfill({ status: 500, body: 'Internal Error' })
  );
}
```

**Opción 3: offline test:**
```javascript
async ({ context }) => {
  await context.setOffline(true);
}
```

Después de cada mock, `browser_navigate` a la ruta afectada y `browser_snapshot` para verificar que el UI maneja el caso bien (skeleton, error message, retry button).

**Opción 4 (fallback):** pedir al usuario que configure el server Playwright MCP con throttling vía config file, o usar DevTools del browser abierto manualmente.

---

**Ejecutá AHORA. No pidas permiso. No preguntes qué parte primero. Arrancá en §0 (pre-flight Playwright) y no pares hasta que §7 digan todos sí.**
