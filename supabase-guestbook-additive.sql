-- 구구SONGBOOK 방명록 추가 설정 (기존 테이블/정책은 변경하지 않습니다)
-- Supabase SQL Editor에서 검토 후 실행하세요.

create table if not exists public.guestbook_entries (
  id uuid primary key default gen_random_uuid(),
  nickname text check (nickname is null or char_length(nickname) <= 40),
  content text not null check (char_length(btrim(content)) between 1 and 300),
  created_at timestamptz not null default now()
);

alter table public.guestbook_entries enable row level security;
grant select, insert on public.guestbook_entries to anon, authenticated;
grant delete on public.guestbook_entries to authenticated;

drop policy if exists "guestbook public read" on public.guestbook_entries;
create policy "guestbook public read" on public.guestbook_entries
  for select to anon, authenticated using (true);

drop policy if exists "guestbook public insert" on public.guestbook_entries;
create policy "guestbook public insert" on public.guestbook_entries
  for insert to anon, authenticated
  with check (
    char_length(btrim(content)) between 1 and 300
    and (nickname is null or char_length(nickname) <= 40)
  );

drop policy if exists "guestbook admins delete" on public.guestbook_entries;
create policy "guestbook admins delete" on public.guestbook_entries
  for delete to authenticated
  using (auth.uid() in (
    'c5baad4d-b1e5-4650-9713-f964062b00c6'::uuid,
    'f36d52d1-411b-4ee7-86aa-dc7157ee6d69'::uuid
  ));

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'guestbook_entries'
  ) then
    alter publication supabase_realtime add table public.guestbook_entries;
  end if;
end $$;
