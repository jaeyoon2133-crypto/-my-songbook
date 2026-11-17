# MY SONGBOOK V7

기존 V5의 흰색·보라색 디자인과 검색, 초성 검색, 카테고리, 즐겨찾기, 난이도, 오늘의 컨디션, 백업 기능을 유지하고 저장·권한 시스템을 Supabase로 교체한 버전입니다.

## V7에서 바뀐 점
- 노래/컨디션 저장은 Supabase DB에 즉시 반영됩니다. GitHub 커밋이나 Netlify 재배포가 필요하지 않습니다.
- 노래는 기존 노래책 카테고리로만 관리합니다. 카테고리 순서는 자신있는 노래, 집중이 필요한 노래, 부르기 힘든 노래, 연습 중입니다.
- 신청곡은 공유 DB에 저장되어 관리자 보관함에 표시됩니다.
- Supabase Realtime으로 노래책과 신청곡 보관함을 자동 갱신합니다.
- 관리자 로그인은 Supabase Auth를 사용하고, RLS 정책에서 지정된 관리자 UUID만 노래 수정/신청곡 열람·관리할 수 있습니다.
- 즐겨찾기와 곡별 메모는 기존처럼 현재 브라우저에 개인 저장됩니다.

## 최초 1회 설정
1. https://supabase.com 에서 프로젝트를 생성합니다.
2. Authentication → Users에서 관리자 계정을 생성합니다. 이메일/비밀번호를 기억해 둡니다.
3. 관리자 사용자 UUID를 복사합니다.
4. SQL Editor에서 `supabase-setup.sql`을 열고 `YOUR_ADMIN_USER_UUID`를 실제 UUID로 바꾼 뒤 전체 실행합니다.
5. Project Settings → API에서 Project URL과 `anon` public key를 복사합니다. `service_role` 키는 절대 사용하거나 공개하지 마세요.
6. `config.js`의 `url`, `anonKey`에 두 값을 입력합니다.
7. 이 폴더 전체를 정적 호스팅에 배포합니다. Cloudflare Pages, GitHub Pages 등 정적 호스팅을 사용할 수 있습니다. 빌드 명령은 필요 없고 배포 디렉터리는 프로젝트 루트입니다.

## 기존 V5 데이터 이전
- V5 관리자 화면에서 전체 백업 JSON을 내려받아 둡니다.
- V7를 설정하고 관리자 로그인한 뒤 관리자 설정의 `백업 가져오기`로 JSON을 선택합니다. 노래와 신청곡이 함께 이전됩니다.
- 같은 브라우저에 V5가 남아 있으면 기존 로컬 노래를 감지할 수 있습니다. 관리자 설정의 `기존 노래 클라우드 이전`을 눌러 이전할 수도 있습니다.

## 보안 메모
- Supabase `anon` 키는 웹페이지에 포함되는 공개 키입니다. 보안은 SQL의 Row Level Security 정책이 담당합니다.
- `service_role` 키를 config.js에 넣지 마세요.
- `YOUR_ADMIN_USER_UUID`를 실제 UUID로 바꾸지 않으면 관리자 정책이 작동하지 않습니다.
- 신청곡 입력은 공개 허용이므로 닉네임/메시지에 민감한 개인정보를 남기지 않도록 안내하세요.

## 로컬 미리보기
브라우저에서 `index.html`을 직접 열기보다 VS Code Live Server 또는 `python -m http.server 8000`으로 열어 주세요. `config.js` 설정 전에는 화면은 보이지만 클라우드 저장/로그인/신청곡 공유 기능은 작동하지 않습니다.
