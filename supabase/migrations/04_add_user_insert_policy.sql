-- Add missing INSERT policy for users table
CREATE POLICY "Users can insert their own profile"
ON users FOR INSERT
WITH CHECK (auth.uid() = id);

-- Add a service role policy to allow the trigger function to insert users
CREATE POLICY "Service role can insert users"
ON users FOR INSERT
TO service_role
USING (true);
