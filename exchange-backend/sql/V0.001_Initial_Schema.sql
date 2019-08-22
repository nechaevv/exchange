CREATE TABLE "Users"(
    "id" uuid primary key,
    "name" varchar(50) not null
);

create table "Tickers"(
    "id" uuid primary key,
    "symbol" varchar(30) not null,
    "name" varchar(200) not null,
    "isActive" bool not null
);

create type "OrderType" as enum (
    'IMMEDIATE',
    'FILL_OR_KILL',
    'STOP'
);

create table "Orders"(
    "id" bigserial primary key,
    "tickerId" uuid not null references "Tickers"("id"),
    "userId" uuid not null references "Users"("id"),
    "type" "OrderType" not null,
    "limitPrice" decimal,
    "stopPrice" decimal,
    "amount" decimal not null,
    "isActive" bool not null,
    "orderTime" timestamptz not null
);

create table "Trades"(
    "id" bigserial primary key,
    "tickerId" uuid not null references "Tickers"("id"),
    "tradeTime" timestamp not null,
    "makerOrderId" bigint not null references "Orders"("id"),
    "takerOrderId" bigint not null references "Orders"("id"),
    "amount" decimal not null,
    "price" decimal not null
);

create table "AuthTokens"(
    "token" uuid primary key,
    "userId" uuid not null references "Users"("id"),
    "issueTime" timestamptz not null default now()
);
