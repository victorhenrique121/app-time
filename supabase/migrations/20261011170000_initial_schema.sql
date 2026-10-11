create schema app_private;

revoke all on schema app_private from public, anon, authenticated;
grant usage on schema app_private to authenticated;

create table public.teams (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(btrim(name)) between 1 and 100),
  timezone text not null default 'America/Sao_Paulo',
  crest_path text,
  created_by uuid not null references auth.users (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.profiles (
  id uuid primary key references auth.users (id) on delete restrict,
  display_name text not null check (char_length(btrim(display_name)) between 1 and 80),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.team_members (
  team_id uuid not null references public.teams (id) on delete restrict,
  user_id uuid not null references auth.users (id) on delete restrict,
  role text not null check (role in ('admin', 'player')),
  status text not null check (status in ('invited', 'active', 'inactive')),
  created_by uuid not null references auth.users (id) on delete restrict,
  created_at timestamptz not null default now(),
  joined_at timestamptz,
  primary key (team_id, user_id),
  check (
    (status = 'active' and joined_at is not null)
    or (status <> 'active')
  )
);

create index team_members_user_status_idx
  on public.team_members (user_id, status, team_id);

create table public.players (
  team_id uuid not null,
  user_id uuid not null,
  preferred_position text
    check (preferred_position is null or char_length(btrim(preferred_position)) <= 40),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (team_id, user_id),
  foreign key (team_id, user_id)
    references public.team_members (team_id, user_id) on delete restrict
);

create table public.matches (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams (id) on delete restrict,
  starts_at timestamptz not null,
  venue text not null check (char_length(btrim(venue)) between 1 and 120),
  modality text not null default 'fut7'
    check (modality in ('society', 'fut6', 'fut7')),
  notes text check (notes is null or char_length(notes) <= 2000),
  capacity integer not null check (capacity > 0),
  response_deadline timestamptz not null,
  status text not null default 'planned'
    check (status in ('planned', 'confirmed', 'completed', 'cancelled')),
  created_by uuid not null references auth.users (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (team_id, id),
  check (response_deadline <= starts_at)
);

create index matches_team_starts_at_idx
  on public.matches (team_id, starts_at desc);

create table public.match_responses (
  team_id uuid not null,
  match_id uuid not null,
  user_id uuid not null,
  response_status text not null
    check (response_status in ('confirmed', 'not_going', 'waitlisted')),
  response_order bigint,
  attended boolean,
  responded_at timestamptz not null default now(),
  primary key (team_id, match_id, user_id),
  foreign key (team_id, match_id)
    references public.matches (team_id, id) on delete restrict,
  foreign key (team_id, user_id)
    references public.team_members (team_id, user_id) on delete restrict,
  check (
    (response_status = 'not_going' and response_order is null)
    or (response_status in ('confirmed', 'waitlisted') and response_order > 0)
  ),
  unique (team_id, match_id, response_order)
);

create index match_responses_waitlist_idx
  on public.match_responses (team_id, match_id, response_order)
  where response_status = 'waitlisted';

create table public.charges (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null,
  player_user_id uuid not null,
  description text not null check (char_length(btrim(description)) between 1 and 200),
  amount numeric(12, 2) not null check (amount > 0),
  due_date date,
  status text not null default 'active' check (status in ('active', 'cancelled')),
  cancellation_reason text,
  cancelled_by uuid references auth.users (id) on delete restrict,
  cancelled_at timestamptz,
  created_by uuid not null default auth.uid()
    references auth.users (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (team_id, player_user_id)
    references public.team_members (team_id, user_id) on delete restrict,
  unique (team_id, id),
  check (
    (status = 'active'
      and cancellation_reason is null
      and cancelled_by is null
      and cancelled_at is null)
    or (status = 'cancelled'
      and char_length(btrim(cancellation_reason)) > 0
      and cancelled_by is not null
      and cancelled_at is not null)
  )
);

create index charges_team_player_idx
  on public.charges (team_id, player_user_id, created_at desc);

create table public.payments (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null,
  charge_id uuid not null,
  amount numeric(12, 2) not null check (amount > 0),
  method text check (method is null or method in ('pix', 'cash', 'transfer', 'other')),
  idempotency_key uuid not null,
  status text not null default 'posted' check (status in ('posted', 'reversed')),
  paid_at timestamptz not null default now(),
  created_by uuid not null references auth.users (id) on delete restrict,
  reversed_by uuid references auth.users (id) on delete restrict,
  reversed_at timestamptz,
  reversal_reason text,
  created_at timestamptz not null default now(),
  foreign key (team_id, charge_id)
    references public.charges (team_id, id) on delete restrict,
  unique (team_id, idempotency_key),
  check (
    (status = 'posted'
      and reversed_by is null
      and reversed_at is null
      and reversal_reason is null)
    or (status = 'reversed'
      and reversed_by is not null
      and reversed_at is not null
      and char_length(btrim(reversal_reason)) > 0)
  )
);

create index payments_team_charge_status_idx
  on public.payments (team_id, charge_id, status);

create table public.expenses (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams (id) on delete restrict,
  amount numeric(12, 2) not null check (amount > 0),
  category text not null check (char_length(btrim(category)) between 1 and 60),
  description text not null check (char_length(btrim(description)) between 1 and 500),
  incurred_at timestamptz not null default now(),
  status text not null default 'posted' check (status in ('posted', 'reversed')),
  created_by uuid not null default auth.uid()
    references auth.users (id) on delete restrict,
  created_at timestamptz not null default now(),
  reversed_by uuid references auth.users (id) on delete restrict,
  reversed_at timestamptz,
  reversal_reason text,
  check (
    (status = 'posted'
      and reversed_by is null
      and reversed_at is null
      and reversal_reason is null)
    or (status = 'reversed'
      and reversed_by is not null
      and reversed_at is not null
      and char_length(btrim(reversal_reason)) > 0)
  )
);

create index expenses_team_incurred_at_idx
  on public.expenses (team_id, incurred_at desc);

create table public.financial_audit (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams (id) on delete restrict,
  actor_user_id uuid not null references auth.users (id) on delete restrict,
  action text not null check (
    action in ('charge_cancelled', 'payment_recorded', 'payment_reversed', 'expense_reversed')
  ),
  entity_type text not null check (entity_type in ('charge', 'payment', 'expense')),
  entity_id uuid not null,
  reason text check (reason is null or char_length(btrim(reason)) between 1 and 500),
  created_at timestamptz not null default now()
);

create index financial_audit_team_created_idx
  on public.financial_audit (team_id, created_at desc);

create or replace function app_private.touch_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger teams_touch_updated_at
before update on public.teams
for each row execute function app_private.touch_updated_at();

create trigger profiles_touch_updated_at
before update on public.profiles
for each row execute function app_private.touch_updated_at();

create trigger players_touch_updated_at
before update on public.players
for each row execute function app_private.touch_updated_at();

create trigger matches_touch_updated_at
before update on public.matches
for each row execute function app_private.touch_updated_at();

create trigger charges_touch_updated_at
before update on public.charges
for each row execute function app_private.touch_updated_at();

create or replace function app_private.is_active_member(p_team_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.team_members as membership
    where membership.team_id = p_team_id
      and membership.user_id = (select auth.uid())
      and membership.status = 'active'
  );
$$;

create or replace function app_private.is_team_admin(p_team_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.team_members as membership
    where membership.team_id = p_team_id
      and membership.user_id = (select auth.uid())
      and membership.status = 'active'
      and membership.role = 'admin'
  );
$$;

create or replace function app_private.promote_waitlist(
  p_team_id uuid,
  p_match_id uuid,
  p_capacity integer
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_confirmed_count integer;
  v_next_user_id uuid;
begin
  loop
    select count(*)::integer
    into v_confirmed_count
    from public.match_responses as response
    join public.team_members as membership
      on membership.team_id = response.team_id
      and membership.user_id = response.user_id
    where response.team_id = p_team_id
      and response.match_id = p_match_id
      and response.response_status = 'confirmed'
      and membership.status = 'active';

    exit when v_confirmed_count >= p_capacity;

    select response.user_id
    into v_next_user_id
    from public.match_responses as response
    join public.team_members as membership
      on membership.team_id = response.team_id
      and membership.user_id = response.user_id
    where response.team_id = p_team_id
      and response.match_id = p_match_id
      and response.response_status = 'waitlisted'
      and membership.status = 'active'
    order by response.response_order, response.user_id
    limit 1
    for update of response;

    exit when not found;

    update public.match_responses
    set response_status = 'confirmed',
        responded_at = now()
    where team_id = p_team_id
      and match_id = p_match_id
      and user_id = v_next_user_id;
  end loop;
end;
$$;

create or replace function public.respond_to_match(
  p_match_id uuid,
  p_response text
)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_match public.matches%rowtype;
  v_current_status text;
  v_has_response boolean;
  v_response_order bigint;
  v_confirmed_count integer;
  v_new_status text;
begin
  if p_response is null or p_response not in ('confirmed', 'not_going') then
    raise exception 'Response must be confirmed or not_going'
      using errcode = '22023';
  end if;

  select *
  into v_match
  from public.matches
  where id = p_match_id
  for update;

  if not found then
    raise exception 'Match unavailable'
      using errcode = '42501';
  end if;

  if not app_private.is_active_member(v_match.team_id) then
    raise exception 'Match unavailable'
      using errcode = '42501';
  end if;

  if v_match.status not in ('planned', 'confirmed') then
    raise exception 'This match is not open for responses'
      using errcode = '23514';
  end if;

  select response.response_status
  into v_current_status
  from public.match_responses as response
  where response.team_id = v_match.team_id
    and response.match_id = v_match.id
    and response.user_id = (select auth.uid())
  for update;
  v_has_response := found;

  if p_response = 'confirmed'
      and v_has_response
      and v_current_status in ('confirmed', 'waitlisted') then
    return v_current_status;
  end if;

  if p_response = 'not_going'
      and v_has_response
      and v_current_status = 'not_going' then
    return v_current_status;
  end if;

  if v_match.starts_at <= now() then
    raise exception 'This match has already started'
      using errcode = '23514';
  end if;

  if p_response = 'not_going' then
    if v_has_response then
      update public.match_responses
      set response_status = 'not_going',
          response_order = null,
          responded_at = now()
      where team_id = v_match.team_id
        and match_id = v_match.id
        and user_id = (select auth.uid());

      if v_current_status = 'confirmed' then
        perform app_private.promote_waitlist(
          v_match.team_id,
          v_match.id,
          v_match.capacity
        );
      end if;
    else
      insert into public.match_responses (
        team_id,
        match_id,
        user_id,
        response_status
      )
      values (
        v_match.team_id,
        v_match.id,
        (select auth.uid()),
        'not_going'
      );
    end if;

    return 'not_going';
  end if;

  if not v_has_response and now() > v_match.response_deadline then
    raise exception 'The response deadline has passed'
      using errcode = '23514';
  end if;

  perform app_private.promote_waitlist(
    v_match.team_id,
    v_match.id,
    v_match.capacity
  );

  select response.response_status
  into v_current_status
  from public.match_responses as response
  where response.team_id = v_match.team_id
    and response.match_id = v_match.id
    and response.user_id = (select auth.uid());
  v_has_response := found;

  if v_has_response and v_current_status in ('confirmed', 'waitlisted') then
    return v_current_status;
  end if;

  select coalesce(max(response.response_order), 0) + 1
  into v_response_order
  from public.match_responses as response
  where response.team_id = v_match.team_id
    and response.match_id = v_match.id;

  select count(*)::integer
  into v_confirmed_count
  from public.match_responses as response
  join public.team_members as membership
    on membership.team_id = response.team_id
    and membership.user_id = response.user_id
  where response.team_id = v_match.team_id
    and response.match_id = v_match.id
    and response.response_status = 'confirmed'
    and membership.status = 'active';

  v_new_status := case
    when v_confirmed_count < v_match.capacity then 'confirmed'
    else 'waitlisted'
  end;

  if v_has_response then
    update public.match_responses
    set response_status = v_new_status,
        response_order = v_response_order,
        responded_at = now()
    where team_id = v_match.team_id
      and match_id = v_match.id
      and user_id = (select auth.uid());
  else
    insert into public.match_responses (
      team_id,
      match_id,
      user_id,
      response_status,
      response_order
    )
    values (
      v_match.team_id,
      v_match.id,
      (select auth.uid()),
      v_new_status,
      v_response_order
    );
  end if;

  return v_new_status;
end;
$$;

create or replace function public.record_charge_payment(
  p_charge_id uuid,
  p_amount numeric,
  p_method text,
  p_idempotency_key uuid
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_charge public.charges%rowtype;
  v_existing public.payments%rowtype;
  v_payment_id uuid;
  v_paid_amount numeric(12, 2);
begin
  if p_amount is null or p_amount <= 0 then
    raise exception 'Payment amount must be greater than zero'
      using errcode = '23514';
  end if;

  if p_idempotency_key is null then
    raise exception 'An idempotency key is required'
      using errcode = '22023';
  end if;

  select *
  into v_charge
  from public.charges
  where id = p_charge_id
  for update;

  if not found then
    raise exception 'Charge unavailable or unauthorized'
      using errcode = '42501';
  end if;

  if not app_private.is_team_admin(v_charge.team_id) then
    raise exception 'Charge unavailable or unauthorized'
      using errcode = '42501';
  end if;

  select *
  into v_existing
  from public.payments
  where team_id = v_charge.team_id
    and idempotency_key = p_idempotency_key;

  if found then
    if v_existing.charge_id <> p_charge_id
        or v_existing.amount <> p_amount
        or v_existing.method is distinct from p_method then
      raise exception 'Idempotency key was already used with different payment data'
        using errcode = '23505';
    end if;

    return v_existing.id;
  end if;

  if v_charge.status <> 'active' then
    raise exception 'Cancelled charges cannot receive payments'
      using errcode = '23514';
  end if;

  select coalesce(sum(payment.amount), 0)
  into v_paid_amount
  from public.payments as payment
  where payment.team_id = v_charge.team_id
    and payment.charge_id = v_charge.id
    and payment.status = 'posted';

  if p_amount > v_charge.amount - v_paid_amount then
    raise exception 'Payment exceeds unpaid charge balance'
      using errcode = '23514';
  end if;

  insert into public.payments (
    team_id,
    charge_id,
    amount,
    method,
    idempotency_key,
    created_by
  )
  values (
    v_charge.team_id,
    v_charge.id,
    p_amount,
    p_method,
    p_idempotency_key,
    (select auth.uid())
  )
  on conflict (team_id, idempotency_key) do nothing
  returning id into v_payment_id;

  if v_payment_id is null then
    select *
    into v_existing
    from public.payments
    where team_id = v_charge.team_id
      and idempotency_key = p_idempotency_key;

    if v_existing.charge_id <> p_charge_id
        or v_existing.amount <> p_amount
        or v_existing.method is distinct from p_method then
      raise exception 'Idempotency key was already used with different payment data'
        using errcode = '23505';
    end if;

    return v_existing.id;
  end if;

  insert into public.financial_audit (
    team_id,
    actor_user_id,
    action,
    entity_type,
    entity_id
  )
  values (
    v_charge.team_id,
    (select auth.uid()),
    'payment_recorded',
    'payment',
    v_payment_id
  );

  return v_payment_id;
end;
$$;

create or replace function public.reverse_payment(
  p_payment_id uuid,
  p_reason text
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_payment public.payments%rowtype;
begin
  if p_reason is null or char_length(btrim(p_reason)) not between 1 and 500 then
    raise exception 'A reversal reason of 1 to 500 characters is required'
      using errcode = '23514';
  end if;

  select *
  into v_payment
  from public.payments
  where id = p_payment_id
  for update;

  if not found then
    raise exception 'Payment unavailable or unauthorized'
      using errcode = '42501';
  end if;

  if not app_private.is_team_admin(v_payment.team_id) then
    raise exception 'Payment unavailable or unauthorized'
      using errcode = '42501';
  end if;

  if v_payment.status <> 'posted' then
    raise exception 'Only posted payments can be reversed'
      using errcode = '23514';
  end if;

  update public.payments
  set status = 'reversed',
      reversed_by = (select auth.uid()),
      reversed_at = now(),
      reversal_reason = btrim(p_reason)
  where id = v_payment.id;

  insert into public.financial_audit (
    team_id,
    actor_user_id,
    action,
    entity_type,
    entity_id,
    reason
  )
  values (
    v_payment.team_id,
    (select auth.uid()),
    'payment_reversed',
    'payment',
    v_payment.id,
    btrim(p_reason)
  );
end;
$$;

create or replace function public.cancel_charge(
  p_charge_id uuid,
  p_reason text
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_charge public.charges%rowtype;
  v_posted_payment_exists boolean;
begin
  if p_reason is null or char_length(btrim(p_reason)) not between 1 and 500 then
    raise exception 'A cancellation reason of 1 to 500 characters is required'
      using errcode = '23514';
  end if;

  select *
  into v_charge
  from public.charges
  where id = p_charge_id
  for update;

  if not found then
    raise exception 'Charge unavailable or unauthorized'
      using errcode = '42501';
  end if;

  if not app_private.is_team_admin(v_charge.team_id) then
    raise exception 'Charge unavailable or unauthorized'
      using errcode = '42501';
  end if;

  if v_charge.status <> 'active' then
    raise exception 'Only active charges can be cancelled'
      using errcode = '23514';
  end if;

  select exists (
    select 1
    from public.payments as payment
    where payment.team_id = v_charge.team_id
      and payment.charge_id = v_charge.id
      and payment.status = 'posted'
  )
  into v_posted_payment_exists;

  if v_posted_payment_exists then
    raise exception 'Reverse posted payments before cancelling the charge'
      using errcode = '23514';
  end if;

  update public.charges
  set status = 'cancelled',
      cancellation_reason = btrim(p_reason),
      cancelled_by = (select auth.uid()),
      cancelled_at = now()
  where id = v_charge.id;

  insert into public.financial_audit (
    team_id,
    actor_user_id,
    action,
    entity_type,
    entity_id,
    reason
  )
  values (
    v_charge.team_id,
    (select auth.uid()),
    'charge_cancelled',
    'charge',
    v_charge.id,
    btrim(p_reason)
  );
end;
$$;

create or replace function public.reverse_expense(
  p_expense_id uuid,
  p_reason text
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_expense public.expenses%rowtype;
begin
  if p_reason is null or char_length(btrim(p_reason)) not between 1 and 500 then
    raise exception 'A reversal reason of 1 to 500 characters is required'
      using errcode = '23514';
  end if;

  select *
  into v_expense
  from public.expenses
  where id = p_expense_id
  for update;

  if not found then
    raise exception 'Expense unavailable or unauthorized'
      using errcode = '42501';
  end if;

  if not app_private.is_team_admin(v_expense.team_id) then
    raise exception 'Expense unavailable or unauthorized'
      using errcode = '42501';
  end if;

  if v_expense.status <> 'posted' then
    raise exception 'Only posted expenses can be reversed'
      using errcode = '23514';
  end if;

  update public.expenses
  set status = 'reversed',
      reversed_by = (select auth.uid()),
      reversed_at = now(),
      reversal_reason = btrim(p_reason)
  where id = v_expense.id;

  insert into public.financial_audit (
    team_id,
    actor_user_id,
    action,
    entity_type,
    entity_id,
    reason
  )
  values (
    v_expense.team_id,
    (select auth.uid()),
    'expense_reversed',
    'expense',
    v_expense.id,
    btrim(p_reason)
  );
end;
$$;

alter table public.teams enable row level security;
alter table public.profiles enable row level security;
alter table public.team_members enable row level security;
alter table public.players enable row level security;
alter table public.matches enable row level security;
alter table public.match_responses enable row level security;
alter table public.charges enable row level security;
alter table public.payments enable row level security;
alter table public.expenses enable row level security;
alter table public.financial_audit enable row level security;

create policy teams_select_active_members
  on public.teams for select to authenticated
  using ((select app_private.is_active_member(id)));

create policy teams_update_admins
  on public.teams for update to authenticated
  using ((select app_private.is_team_admin(id)))
  with check ((select app_private.is_team_admin(id)));

create policy profiles_select_own_or_shared_team
  on public.profiles for select to authenticated
  using (
    id = (select auth.uid())
    or exists (
      select 1
      from public.team_members as target_membership
      where target_membership.user_id = profiles.id
        and target_membership.status = 'active'
        and (select app_private.is_active_member(target_membership.team_id))
    )
  );

create policy profiles_insert_own
  on public.profiles for insert to authenticated
  with check (id = (select auth.uid()));

create policy profiles_update_own
  on public.profiles for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

create policy team_members_select_own_active_team_or_admin
  on public.team_members for select to authenticated
  using (
    user_id = (select auth.uid())
    or (
      status = 'active'
      and (select app_private.is_active_member(team_id))
    )
    or (select app_private.is_team_admin(team_id))
  );

create policy team_members_insert_admins
  on public.team_members for insert to authenticated
  with check (
    (select app_private.is_team_admin(team_id))
    and created_by = (select auth.uid())
  );

create policy team_members_update_admins
  on public.team_members for update to authenticated
  using ((select app_private.is_team_admin(team_id)))
  with check ((select app_private.is_team_admin(team_id)));

create policy players_select_self_or_admin
  on public.players for select to authenticated
  using (
    (
      user_id = (select auth.uid())
      and (select app_private.is_active_member(team_id))
    )
    or (select app_private.is_team_admin(team_id))
  );

create policy players_insert_admins
  on public.players for insert to authenticated
  with check ((select app_private.is_team_admin(team_id)));

create policy players_update_self_or_admin
  on public.players for update to authenticated
  using (
    (
      user_id = (select auth.uid())
      and (select app_private.is_active_member(team_id))
    )
    or (select app_private.is_team_admin(team_id))
  )
  with check (
    (
      user_id = (select auth.uid())
      and (select app_private.is_active_member(team_id))
    )
    or (select app_private.is_team_admin(team_id))
  );

create policy matches_select_active_members
  on public.matches for select to authenticated
  using ((select app_private.is_active_member(team_id)));

create policy matches_insert_admins
  on public.matches for insert to authenticated
  with check (
    (select app_private.is_team_admin(team_id))
    and created_by = (select auth.uid())
  );

create policy matches_update_admins
  on public.matches for update to authenticated
  using ((select app_private.is_team_admin(team_id)))
  with check ((select app_private.is_team_admin(team_id)));

create policy match_responses_select_self_or_admin
  on public.match_responses for select to authenticated
  using (
    (
      user_id = (select auth.uid())
      and (select app_private.is_active_member(team_id))
    )
    or (select app_private.is_team_admin(team_id))
  );

create policy match_responses_update_attendance_admins
  on public.match_responses for update to authenticated
  using ((select app_private.is_team_admin(team_id)))
  with check ((select app_private.is_team_admin(team_id)));

create policy charges_select_owner_or_admin
  on public.charges for select to authenticated
  using (
    (
      player_user_id = (select auth.uid())
      and (select app_private.is_active_member(team_id))
    )
    or (select app_private.is_team_admin(team_id))
  );

create policy charges_insert_admins
  on public.charges for insert to authenticated
  with check (
    (select app_private.is_team_admin(team_id))
    and created_by = (select auth.uid())
  );

create policy payments_select_charge_owner_or_admin
  on public.payments for select to authenticated
  using (
    (select app_private.is_team_admin(team_id))
    or exists (
      select 1
      from public.charges as charge
      where charge.team_id = payments.team_id
        and charge.id = payments.charge_id
        and charge.player_user_id = (select auth.uid())
        and (select app_private.is_active_member(charge.team_id))
    )
  );

create policy expenses_select_admins
  on public.expenses for select to authenticated
  using ((select app_private.is_team_admin(team_id)));

create policy expenses_insert_admins
  on public.expenses for insert to authenticated
  with check (
    (select app_private.is_team_admin(team_id))
    and created_by = (select auth.uid())
  );

create policy financial_audit_select_admins
  on public.financial_audit for select to authenticated
  using ((select app_private.is_team_admin(team_id)));

revoke all on public.teams, public.profiles, public.team_members, public.players,
  public.matches, public.match_responses, public.charges, public.payments,
  public.expenses, public.financial_audit
  from anon, authenticated;
grant select, update (name, timezone, crest_path)
  on public.teams to authenticated;
grant select, insert (id, display_name), update (display_name)
  on public.profiles to authenticated;
grant select,
  insert (team_id, user_id, role, status, created_by),
  update (role, status, joined_at)
  on public.team_members to authenticated;
grant select, insert (team_id, user_id, preferred_position),
  update (preferred_position)
  on public.players to authenticated;
grant select,
  insert (team_id, starts_at, venue, modality, notes, capacity, response_deadline, status, created_by),
  update (starts_at, venue, modality, notes, capacity, response_deadline, status)
  on public.matches to authenticated;
grant select, update (attended) on public.match_responses to authenticated;
grant select, insert (team_id, player_user_id, description, amount, due_date, created_by)
  on public.charges to authenticated;
grant select on public.payments, public.expenses, public.financial_audit
  to authenticated;
grant insert (team_id, amount, category, description, incurred_at, created_by)
  on public.expenses to authenticated;

revoke all on function app_private.touch_updated_at() from public, anon, authenticated;
revoke all on function app_private.is_active_member(uuid) from public, anon, authenticated;
revoke all on function app_private.is_team_admin(uuid) from public, anon, authenticated;
revoke all on function app_private.promote_waitlist(uuid, uuid, integer)
  from public, anon, authenticated;
grant execute on function app_private.is_active_member(uuid) to authenticated;
grant execute on function app_private.is_team_admin(uuid) to authenticated;

revoke all on function public.respond_to_match(uuid, text) from public, anon, authenticated;
revoke all on function public.record_charge_payment(uuid, numeric, text, uuid)
  from public, anon, authenticated;
revoke all on function public.reverse_payment(uuid, text) from public, anon, authenticated;
revoke all on function public.cancel_charge(uuid, text) from public, anon, authenticated;
revoke all on function public.reverse_expense(uuid, text) from public, anon, authenticated;
grant execute on function public.respond_to_match(uuid, text) to authenticated;
grant execute on function public.record_charge_payment(uuid, numeric, text, uuid)
  to authenticated;
grant execute on function public.reverse_payment(uuid, text) to authenticated;
grant execute on function public.cancel_charge(uuid, text) to authenticated;
grant execute on function public.reverse_expense(uuid, text) to authenticated;
