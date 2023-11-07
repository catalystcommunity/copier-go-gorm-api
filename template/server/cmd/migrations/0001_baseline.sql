-- +goose Up
CREATE
EXTENSION IF NOT EXISTS "uuid-ossp";

create table hellos
(
    id                       uuid      default uuid_generate_v4() not null primary key,
    created_at               timestamp default now(),
    updated_at               timestamp default now(),
    hello_type               bigint,
    person_name              text
);
