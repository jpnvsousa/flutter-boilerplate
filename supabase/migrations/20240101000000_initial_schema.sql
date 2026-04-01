-- ============================================================
-- Migration: Initial Schema
-- Created: 2024-01-01
-- Description: Core tables required by the boilerplate.
--   - profiles (extends auth.users)
--   - RLS policies for profiles
--   - Trigger to auto-create profile on signup
-- ============================================================

-- ── profiles ─────────────────────────────────────────────────────────────────
-- Extends Supabase auth.users with app-specific fields.
-- plan: 'free' | 'trial' | 'pro'
-- trial_ends_at: set to now() + 14 days on signup via trigger

create table if not exists public.profiles (
  id            uuid        references auth.users on delete cascade primary key,
  email         text        unique not null,
  full_name     text,
  avatar_url    text,
  plan          text        not null default 'trial'
                              check (plan in ('free', 'trial', 'pro')),
  trial_ends_at timestamptz,
  rc_customer_id text,             -- RevenueCat customer ID
  fcm_token     text,              -- Firebase Cloud Messaging token
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- ── Indexes ───────────────────────────────────────────────────────────────────
create index if not exists profiles_email_idx on public.profiles (email);
create index if not exists profiles_plan_idx  on public.profiles (plan);

-- ── Row Level Security ────────────────────────────────────────────────────────
alter table public.profiles enable row level security;

-- Users can only read/write their own profile
create policy "profiles: select own"
  on public.profiles for select
  using (auth.uid() = id);

create policy "profiles: insert own"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "profiles: update own"
  on public.profiles for update
  using (auth.uid() = id);

-- ── Auto-update updated_at ────────────────────────────────────────────────────
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger profiles_updated_at
  before update on public.profiles
  for each row execute procedure update_updated_at_column();

-- ── Auto-create profile on signup ─────────────────────────────────────────────
-- This trigger runs when a new user signs up via Supabase Auth.
-- Sets plan='trial' and trial_ends_at=now()+14days automatically.

create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (
    id,
    email,
    full_name,
    avatar_url,
    plan,
    trial_ends_at
  )
  values (
    new.id,
    new.email,
    coalesce(
      new.raw_user_meta_data->>'full_name',
      new.raw_user_meta_data->>'name'
    ),
    new.raw_user_meta_data->>'avatar_url',
    'trial',
    now() + interval '14 days'
  )
  on conflict (id) do nothing;  -- Idempotent: safe to run multiple times

  return new;
end;
$$ language plpgsql security definer;

-- Drop and recreate to allow re-running migration
drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
