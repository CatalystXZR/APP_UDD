-- Hito 0 — Esquema Supabase (PostgreSQL) para BVO Matemática.
--
-- Catálogo paramétrico (fuente: PDFs -> assets/seed/families_seed.json ->
-- supabase/migrations/0002_seed_families.sql, generado, no editar a mano).
-- MVP sin login: lectura abierta del catálogo; test_sessions/answers quedan
-- preparados para la fase con autenticación (user_id nullable por ahora).

-- Niveles con su tiempo por pregunta (Básico 60s, Medio 90s, Experto 180s).
create table if not exists difficulties (
  key text primary key,
  label text not null,
  seconds_per_question integer not null
);

-- Una fila por familia del banco paramétrico (21 en MVP: 3 niveles x 7).
-- tuples_json: lista cerrada de tuplas autorizadas [{raw:[...], values:[...]}].
-- domain_json: solo cuando el PDF autoriza un dominio en vez de tuplas
--   (hoy: basico/F4 monotonía inmediata).
-- params_json: [{name, kind, [symbols]}] describe cada componente.
create table if not exists families (
  id text primary key,
  level_key text not null references difficulties(key),
  family_index integer not null,
  generator_key text not null,
  title text not null,
  prompt text,
  template_latex text not null,
  conditions text,
  params_json jsonb not null default '[]',
  tuples_json jsonb not null default '[]',
  domain_json jsonb,
  control_latex text,
  unique (level_key, family_index)
);

-- Preparado post-login (MVP: sin uso, user_id nullable).
create table if not exists test_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  level_key text not null references difficulties(key),
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  score numeric(2,1)
);

create table if not exists answers (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references test_sessions(id) on delete cascade,
  family_id text not null references families(id),
  tuple_index integer,
  question_json jsonb not null,
  correct boolean not null
);

-- MVP sin login: lectura pública del catálogo, escritura solo vía service key.
alter table difficulties enable row level security;
alter table families enable row level security;

drop policy if exists "catalogo lectura publica" on difficulties;
create policy "catalogo lectura publica" on difficulties
  for select using (true);

drop policy if exists "catalogo lectura publica" on families;
create policy "catalogo lectura publica" on families
  for select using (true);
