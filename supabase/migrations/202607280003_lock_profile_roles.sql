-- Prevent authenticated clients from changing account roles.
-- Role assignment is controlled by the auth signup trigger or trusted server-side administration.

begin;

revoke update on table public.profiles from authenticated;
grant update (full_name, phone, avatar_url) on table public.profiles to authenticated;

commit;
