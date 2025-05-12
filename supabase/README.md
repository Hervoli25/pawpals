# PawPals Supabase Setup

This guide will help you set up the Supabase backend for the PawPals app.

## Prerequisites

- A Supabase account (sign up at [supabase.com](https://supabase.com) if you don't have one)
- An existing Supabase project or create a new one

## Setup Steps

### 1. Get Your Supabase Credentials

1. Go to your Supabase project dashboard
2. Navigate to Project Settings > API
3. Copy the URL and anon key

### 2. Update the Configuration File

1. Open `lib/utils/supabase_config.dart` in your Flutter project
2. Replace the placeholder values with your actual Supabase URL and anon key:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### 3. Set Up Database Tables

1. In your Supabase dashboard, go to the SQL Editor
2. Copy and paste the contents of each SQL file in the `supabase/migrations` folder:
   - First run `01_create_tables.sql`
   - Then run `02_create_triggers.sql`
   - Finally run `03_create_row_level_security.sql`

### 4. Configure Authentication

1. In your Supabase dashboard, go to Authentication > Settings
2. Under Email Auth, make sure "Enable Email Signup" is turned on
3. Configure any additional auth providers you want to use (Google, Facebook, etc.)

### 5. Set Up Storage Buckets

1. In your Supabase dashboard, go to Storage
2. Create the following buckets:
   - `profile-pictures` - for user profile images
   - `dog-pictures` - for dog profile images
   - `place-pictures` - for place images

3. Set the following bucket policies:

For `profile-pictures` and `dog-pictures`:
```sql
CREATE POLICY "Users can view their own files"
ON storage.objects FOR SELECT
USING (auth.uid() = owner);

CREATE POLICY "Users can upload their own files"
ON storage.objects FOR INSERT
WITH CHECK (auth.uid() = owner);

CREATE POLICY "Users can update their own files"
ON storage.objects FOR UPDATE
USING (auth.uid() = owner);

CREATE POLICY "Users can delete their own files"
ON storage.objects FOR DELETE
USING (auth.uid() = owner);
```

For `place-pictures`:
```sql
CREATE POLICY "Anyone can view place pictures"
ON storage.objects FOR SELECT
USING (bucket_id = 'place-pictures');

CREATE POLICY "Only authenticated users can upload place pictures"
ON storage.objects FOR INSERT
WITH CHECK (auth.role() = 'authenticated' AND bucket_id = 'place-pictures');
```

## Testing Your Setup

1. Run your Flutter app
2. Try to sign up for a new account
3. If the signup is successful, check your Supabase dashboard to see if a new user was created in both the Auth and the `users` table

## Troubleshooting

- If you encounter authentication issues, check the Supabase logs in the dashboard
- Make sure your app has internet permissions in the Android and iOS configuration files
- Verify that your Supabase URL and anon key are correct in the config file
