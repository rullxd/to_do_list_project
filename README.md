# To-Do List Project

A modern Flutter application that manages a list of tasks and integrates with Supabase for persistence.

## Features

- Material Design 3 interface with support for task creation, editing, completion toggles, and swipe-to-delete.
- Repository pattern with automatic fallback to an in-memory store when Supabase credentials are not supplied.
- Ready-to-use Supabase integration (CRUD against a `todos` table) once project URL and anon key are provided.

## Getting Started

1. Configure your Supabase project credentials. You can either pass them as compile-time variables:

   ```bash
   flutter run --dart-define=SUPABASE_URL=your-url --dart-define=SUPABASE_ANON_KEY=your-key
   ```

   or edit `lib/config/supabase_config.dart` directly.

2. Ensure the following table exists in Supabase:

   ```sql
   create table if not exists public.todos (
     id uuid primary key default uuid_generate_v4(),
     title text not null,
     description text default '',
     is_complete boolean not null default false,
     created_at timestamp with time zone default timezone('utc'::text, now())
   );
   ```

3. Fetch dependencies and run the app:

   ```bash
   flutter pub get
   flutter run
   ```

If Supabase credentials are not provided, the app will still run with an in-memory task list for local experimentation.
