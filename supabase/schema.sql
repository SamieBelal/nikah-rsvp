-- Run this in your Supabase project: SQL Editor -> New query -> Run
create table public.rsvps (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  attending text not null,          -- 'yes' or 'no'
  party_size int default 0,         -- responder + added guests
  guest_names text default '',      -- '; '-separated additional guests
  phone text default '',
  created_at timestamptz default now()
);

-- Lock the table down: guests may submit, but cannot read anyone's data.
alter table public.rsvps enable row level security;

create policy "Public can submit RSVPs"
  on public.rsvps for insert to anon with check (true);
