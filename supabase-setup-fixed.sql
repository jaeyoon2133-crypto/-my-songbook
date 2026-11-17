-- MY SONGBOOK V7 · Supabase SQL Editor에서 전체 실행
-- 관리자 UUID가 반영된 설치 SQL입니다.

create table if not exists public.songbook_data (
  id integer primary key check (id = 1),
  data jsonb not null default '{"version":6,"songs":[],"condition":{"title":"오늘의 컨디션을 확인해 주세요","body":"목 상태와 오늘 부르고 싶은 분위기를 공유해 보세요.","status":"🎙 컨디션 미설정"}}'::jsonb,
  updated_at timestamptz not null default now()
);
insert into public.songbook_data (id) values (1) on conflict (id) do nothing;

create table if not exists public.song_requests (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 1 and 200),
  artist text not null check (char_length(artist) between 1 and 200),
  nickname text check (char_length(coalesce(nickname,'')) <= 80),
  message text check (char_length(coalesce(message,'')) <= 1000),
  status text not null default '대기' check (status in ('대기','완료')),
  created_at timestamptz not null default now()
);

alter table public.songbook_data enable row level security;
alter table public.song_requests enable row level security;

drop policy if exists "public can read songbook" on public.songbook_data;
create policy "public can read songbook" on public.songbook_data
  for select to anon, authenticated using (true);

drop policy if exists "only owner can update songbook" on public.songbook_data;
create policy "only owner can update songbook" on public.songbook_data
  for update to authenticated
  using (auth.uid() = 'c5baad4d-b1e5-4650-9713-f964062b00c6'::uuid)
  with check (auth.uid() = 'c5baad4d-b1e5-4650-9713-f964062b00c6'::uuid);

drop policy if exists "visitors can submit requests" on public.song_requests;
create policy "visitors can submit requests" on public.song_requests
  for insert to anon, authenticated with check (status = '대기');

drop policy if exists "only owner can read requests" on public.song_requests;
create policy "only owner can read requests" on public.song_requests
  for select to authenticated
  using (auth.uid() = 'c5baad4d-b1e5-4650-9713-f964062b00c6'::uuid);

drop policy if exists "only owner can update requests" on public.song_requests;
create policy "only owner can update requests" on public.song_requests
  for update to authenticated
  using (auth.uid() = 'c5baad4d-b1e5-4650-9713-f964062b00c6'::uuid)
  with check (auth.uid() = 'c5baad4d-b1e5-4650-9713-f964062b00c6'::uuid);

drop policy if exists "only owner can delete requests" on public.song_requests;
create policy "only owner can delete requests" on public.song_requests
  for delete to authenticated
  using (auth.uid() = 'c5baad4d-b1e5-4650-9713-f964062b00c6'::uuid);

-- Realtime 테이블 등록 (이미 등록된 경우 중복 추가하지 않음)
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'songbook_data'
  ) then
    alter publication supabase_realtime add table public.songbook_data;
  end if;

  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'song_requests'
  ) then
    alter publication supabase_realtime add table public.song_requests;
  end if;
end $$;
