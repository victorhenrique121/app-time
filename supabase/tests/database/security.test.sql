create extension if not exists pgtap with schema extensions;

begin;

select plan(34);

insert into auth.users (
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at
)
values
  (
    '10000000-0000-0000-0000-000000000001',
    'authenticated',
    'authenticated',
    'admin-a@example.invalid',
    '',
    now(),
    '{}'::jsonb,
    '{}'::jsonb,
    now(),
    now()
  ),
  (
    '20000000-0000-0000-0000-000000000002',
    'authenticated',
    'authenticated',
    'player-a@example.invalid',
    '',
    now(),
    '{}'::jsonb,
    '{}'::jsonb,
    now(),
    now()
  ),
  (
    '30000000-0000-0000-0000-000000000003',
    'authenticated',
    'authenticated',
    'admin-b@example.invalid',
    '',
    now(),
    '{}'::jsonb,
    '{}'::jsonb,
    now(),
    now()
  ),
  (
    '40000000-0000-0000-0000-000000000004',
    'authenticated',
    'authenticated',
    'inactive-a@example.invalid',
    '',
    now(),
    '{}'::jsonb,
    '{}'::jsonb,
    now(),
    now()
  );

insert into public.teams (id, name, created_by)
values
  (
    'aaaaaaaa-0000-0000-0000-000000000001',
    'Time A',
    '10000000-0000-0000-0000-000000000001'
  ),
  (
    'bbbbbbbb-0000-0000-0000-000000000002',
    'Time B',
    '30000000-0000-0000-0000-000000000003'
  );

insert into public.profiles (id, display_name)
values
  ('10000000-0000-0000-0000-000000000001', 'Admin A'),
  ('20000000-0000-0000-0000-000000000002', 'Jogador A'),
  ('30000000-0000-0000-0000-000000000003', 'Admin B'),
  ('40000000-0000-0000-0000-000000000004', 'Inativo A');

insert into public.team_members (
  team_id,
  user_id,
  role,
  status,
  created_by,
  joined_at
)
values
  (
    'aaaaaaaa-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    'admin',
    'active',
    '10000000-0000-0000-0000-000000000001',
    now()
  ),
  (
    'aaaaaaaa-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000002',
    'player',
    'active',
    '10000000-0000-0000-0000-000000000001',
    now()
  ),
  (
    'bbbbbbbb-0000-0000-0000-000000000002',
    '30000000-0000-0000-0000-000000000003',
    'admin',
    'active',
    '30000000-0000-0000-0000-000000000003',
    now()
  ),
  (
    'aaaaaaaa-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000004',
    'player',
    'inactive',
    '10000000-0000-0000-0000-000000000001',
    null
  );

insert into public.players (team_id, user_id, preferred_position)
values
  (
    'aaaaaaaa-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    'Goleiro'
  ),
  (
    'aaaaaaaa-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000002',
    'Atacante'
  ),
  (
    'bbbbbbbb-0000-0000-0000-000000000002',
    '30000000-0000-0000-0000-000000000003',
    'Defensor'
  ),
  (
    'aaaaaaaa-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000004',
    'Meio-campo'
  );

insert into public.matches (
  id,
  team_id,
  starts_at,
  venue,
  capacity,
  response_deadline,
  created_by
)
values (
  'cccccccc-0000-0000-0000-000000000001',
  'aaaaaaaa-0000-0000-0000-000000000001',
  now() + interval '2 days',
  'Arena de teste',
  1,
  now() + interval '1 day',
  '10000000-0000-0000-0000-000000000001'
);

insert into public.charges (
  id,
  team_id,
  player_user_id,
  description,
  amount,
  created_by
)
values
  (
    'dddddddd-0000-0000-0000-000000000001',
    'aaaaaaaa-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000002',
    'Mensalidade teste',
    100.00,
    '10000000-0000-0000-0000-000000000001'
  ),
  (
    'eeeeeeee-0000-0000-0000-000000000002',
    'bbbbbbbb-0000-0000-0000-000000000002',
    '30000000-0000-0000-0000-000000000003',
    'Mensalidade de outro time',
    50.00,
    '30000000-0000-0000-0000-000000000003'
  ),
  (
    'eeeeeeee-0000-0000-0000-000000000003',
    'aaaaaaaa-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    'Mensalidade do administrador',
    50.00,
    '10000000-0000-0000-0000-000000000001'
  );

insert into public.expenses (
  team_id,
  amount,
  category,
  description,
  created_by
)
values (
  'aaaaaaaa-0000-0000-0000-000000000001',
  25.00,
  'Campo',
  'Aluguel do campo',
  '10000000-0000-0000-0000-000000000001'
);

select ok(
  (
    select bool_and(relrowsecurity)
    from pg_class
    where oid in (
      'public.teams'::regclass,
      'public.profiles'::regclass,
      'public.team_members'::regclass,
      'public.players'::regclass,
      'public.matches'::regclass,
      'public.match_responses'::regclass,
      'public.charges'::regclass,
      'public.payments'::regclass,
      'public.expenses'::regclass,
      'public.financial_audit'::regclass
    )
  ),
  'RLS is enabled for every public application table'
);

set local role anon;
select throws_ok(
  'select * from public.teams',
  '42501',
  'permission denied for table teams',
  'anonymous users cannot read teams'
);
select throws_ok(
  $sql$
    insert into public.teams (name, created_by)
    values ('Equipe anônima', '10000000-0000-0000-0000-000000000001')
  $sql$,
  '42501',
  'permission denied for table teams',
  'anonymous users cannot create teams'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '20000000-0000-0000-0000-000000000002',
  true
);
set local role authenticated;

select is(
  (select count(*)::integer from public.teams),
  1,
  'a player can see only their active team'
);
select is(
  (select count(*)::integer from public.team_members),
  2,
  'a player can see active memberships in their team'
);
select is(
  (select count(*)::integer from public.players),
  1,
  'a player can see only their own player details'
);
select is(
  (select count(*)::integer from public.charges),
  1,
  'a player cannot see another member charge'
);
select is(
  (select count(*)::integer from public.expenses),
  0,
  'a player cannot see team expenses'
);
select is(
  (select count(*)::integer from public.financial_audit),
  0,
  'a player cannot see financial audit records'
);
select is(
  (select count(*)::integer from public.team_members where team_id = 'bbbbbbbb-0000-0000-0000-000000000002'),
  0,
  'a player cannot see another team membership'
);

update public.team_members
set role = 'admin'
where team_id = 'aaaaaaaa-0000-0000-0000-000000000001'
  and user_id = (select auth.uid());
select is(
  (
    select role
    from public.team_members
    where team_id = 'aaaaaaaa-0000-0000-0000-000000000001'
      and user_id = (select auth.uid())
  ),
  'player',
  'a player cannot promote themself to administrator'
);

select throws_ok(
  $sql$
    insert into public.team_members (
      team_id, user_id, role, status, created_by
    )
    values (
      'bbbbbbbb-0000-0000-0000-000000000002',
      '20000000-0000-0000-0000-000000000002',
      'admin',
      'active',
      (select auth.uid())
    )
  $sql$,
  '42501',
  'new row violates row-level security policy for table "team_members"',
  'a player cannot join another team by changing request data'
);

select throws_ok(
  $sql$
    insert into public.match_responses (
      team_id, match_id, user_id, response_status, response_order
    )
    values (
      'aaaaaaaa-0000-0000-0000-000000000001',
      'cccccccc-0000-0000-0000-000000000001',
      (select auth.uid()),
      'confirmed',
      1
    )
  $sql$,
  '42501',
  'permission denied for table match_responses',
  'players cannot bypass the atomic attendance function'
);

select throws_ok(
  $sql$
    select public.record_charge_payment(
      'dddddddd-0000-0000-0000-000000000001',
      10.00,
      'pix',
      'f0000000-0000-0000-0000-000000000001'
    )
  $sql$,
  '42501',
  'Charge unavailable or unauthorized',
  'a player cannot record a payment'
);
select throws_ok(
  'delete from public.charges',
  '42501',
  'permission denied for table charges',
  'a player cannot delete financial records'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000001',
  true
);
set local role authenticated;

select is(
  (select count(*)::integer from public.team_members),
  3,
  'an administrator can see all memberships in their team'
);
select is(
  public.record_charge_payment(
    'dddddddd-0000-0000-0000-000000000001',
    40.00,
    'pix',
    'f0000000-0000-0000-0000-000000000001'
  ),
  public.record_charge_payment(
    'dddddddd-0000-0000-0000-000000000001',
    40.00,
    'pix',
    'f0000000-0000-0000-0000-000000000001'
  ),
  'repeating an idempotency key does not duplicate a payment'
);
select throws_ok(
  $sql$
    select public.record_charge_payment(
      'dddddddd-0000-0000-0000-000000000001',
      70.00,
      'pix',
      'f0000000-0000-0000-0000-000000000002'
    )
  $sql$,
  '23514',
  'Payment exceeds unpaid charge balance',
  'payments cannot exceed the outstanding charge balance'
);

select public.reverse_payment(
  public.record_charge_payment(
    'dddddddd-0000-0000-0000-000000000001',
    40.00,
    'pix',
    'f0000000-0000-0000-0000-000000000001'
  ),
  'Teste de estorno'
);
select is(
  (select count(*)::integer from public.financial_audit),
  2,
  'payment record and reversal are audit logged for administrators'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '20000000-0000-0000-0000-000000000002',
  true
);
set local role authenticated;
select is(
  (select count(*)::integer from public.payments),
  1,
  'a player can see payments related to their own charge'
);
select is(
  (select count(*)::integer from public.match_responses),
  0,
  'no attendance responses exist yet'
);

select set_config(
  'request.jwt.claim.sub',
  '30000000-0000-0000-0000-000000000003',
  true
);
select is(
  (select count(*)::integer from public.charges),
  1,
  'another team administrator sees only their own team financial data'
);
select throws_ok(
  $sql$
    select public.respond_to_match(
      'cccccccc-0000-0000-0000-000000000001',
      'confirmed'
    )
  $sql$,
  '42501',
  'Match unavailable',
  'an administrator from another team cannot respond to this match'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '40000000-0000-0000-0000-000000000004',
  true
);
set local role authenticated;
select is(
  (select count(*)::integer from public.teams),
  0,
  'inactive members cannot access their former team'
);
select is(
  (select count(*)::integer from public.players),
  0,
  'inactive members cannot access player records'
);
select is(
  (select count(*)::integer from public.matches),
  0,
  'inactive members cannot access matches'
);
select is(
  (select count(*)::integer from public.charges),
  0,
  'inactive members cannot access financial records'
);
select throws_ok(
  $sql$
    select public.respond_to_match(
      'cccccccc-0000-0000-0000-000000000001',
      'confirmed'
    )
  $sql$,
  '42501',
  'Match unavailable',
  'inactive members cannot respond to a match'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000001',
  true
);
set local role authenticated;
select is(
  public.respond_to_match(
    'cccccccc-0000-0000-0000-000000000001',
    'confirmed'
  ),
  'confirmed',
  'first response gets the available place'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '20000000-0000-0000-0000-000000000002',
  true
);
set local role authenticated;
select is(
  public.respond_to_match(
    'cccccccc-0000-0000-0000-000000000001',
    'confirmed'
  ),
  'waitlisted',
  'a response beyond capacity enters the waiting list'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '10000000-0000-0000-0000-000000000001',
  true
);
set local role authenticated;
select is(
  public.respond_to_match(
    'cccccccc-0000-0000-0000-000000000001',
    'not_going'
  ),
  'not_going',
  'cancelling a confirmed response succeeds'
);
reset role;

select set_config(
  'request.jwt.claim.sub',
  '20000000-0000-0000-0000-000000000002',
  true
);
set local role authenticated;
select is(
  (
    select response_status
    from public.match_responses
    where team_id = 'aaaaaaaa-0000-0000-0000-000000000001'
      and match_id = 'cccccccc-0000-0000-0000-000000000001'
      and user_id = (select auth.uid())
  ),
  'confirmed',
  'the earliest active waiting-list member is promoted atomically'
);
select is(
  (select count(*)::integer from public.match_responses),
  1,
  'a player cannot see another member attendance response'
);
select is(
  (
    select count(*)::integer
    from public.match_responses
    where team_id = 'aaaaaaaa-0000-0000-0000-000000000001'
      and match_id = 'cccccccc-0000-0000-0000-000000000001'
      and response_status = 'confirmed'
  ),
  1,
  'confirmed responses never exceed match capacity'
);
reset role;

select * from finish();
rollback;
