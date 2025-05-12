-- Enable Row Level Security on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE dogs ENABLE ROW LEVEL SECURITY;
ALTER TABLE playdates ENABLE ROW LEVEL SECURITY;
ALTER TABLE places ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE meal_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- Create policies for users table
CREATE POLICY "Users can view their own profile"
ON users FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
ON users FOR UPDATE
USING (auth.uid() = id);

-- Create policies for dogs table
CREATE POLICY "Users can view their own dogs"
ON dogs FOR SELECT
USING (auth.uid() = owner_id);

CREATE POLICY "Users can insert their own dogs"
ON dogs FOR INSERT
WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update their own dogs"
ON dogs FOR UPDATE
USING (auth.uid() = owner_id);

CREATE POLICY "Users can delete their own dogs"
ON dogs FOR DELETE
USING (auth.uid() = owner_id);

-- Create policies for playdates table
CREATE POLICY "Users can view playdates involving their dogs"
ON playdates FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM dogs
    WHERE (dogs.id = playdates.dog_id1 OR dogs.id = playdates.dog_id2)
    AND dogs.owner_id = auth.uid()
  )
);

CREATE POLICY "Users can insert playdates for their dogs"
ON playdates FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM dogs
    WHERE dogs.id = playdates.dog_id1
    AND dogs.owner_id = auth.uid()
  )
);

CREATE POLICY "Users can update playdates involving their dogs"
ON playdates FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM dogs
    WHERE (dogs.id = playdates.dog_id1 OR dogs.id = playdates.dog_id2)
    AND dogs.owner_id = auth.uid()
  )
);

CREATE POLICY "Users can delete playdates they created"
ON playdates FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM dogs
    WHERE dogs.id = playdates.dog_id1
    AND dogs.owner_id = auth.uid()
  )
);

-- Create policies for places table
CREATE POLICY "Anyone can view places"
ON places FOR SELECT
USING (true);

-- Create policies for appointments table
CREATE POLICY "Users can view appointments for their dogs"
ON appointments FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM dogs
    WHERE dogs.id = appointments.dog_id
    AND dogs.owner_id = auth.uid()
  )
);

CREATE POLICY "Users can insert appointments for their dogs"
ON appointments FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM dogs
    WHERE dogs.id = appointments.dog_id
    AND dogs.owner_id = auth.uid()
  )
);

CREATE POLICY "Users can update appointments for their dogs"
ON appointments FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM dogs
    WHERE dogs.id = appointments.dog_id
    AND dogs.owner_id = auth.uid()
  )
);

CREATE POLICY "Users can delete appointments for their dogs"
ON appointments FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM dogs
    WHERE dogs.id = appointments.dog_id
    AND dogs.owner_id = auth.uid()
  )
);

-- Create policies for meal_plans and meal_items tables
CREATE POLICY "Users can view meal plans for their dogs"
ON meal_plans FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM dogs
    WHERE dogs.id = meal_plans.dog_id
    AND dogs.owner_id = auth.uid()
  )
);

CREATE POLICY "Users can insert meal plans for their dogs"
ON meal_plans FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM dogs
    WHERE dogs.id = meal_plans.dog_id
    AND dogs.owner_id = auth.uid()
  )
);

CREATE POLICY "Users can update meal plans for their dogs"
ON meal_plans FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM dogs
    WHERE dogs.id = meal_plans.dog_id
    AND dogs.owner_id = auth.uid()
  )
);

CREATE POLICY "Users can delete meal plans for their dogs"
ON meal_plans FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM dogs
    WHERE dogs.id = meal_plans.dog_id
    AND dogs.owner_id = auth.uid()
  )
);

CREATE POLICY "Users can view meal items for their meal plans"
ON meal_items FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM meal_plans
    JOIN dogs ON dogs.id = meal_plans.dog_id
    WHERE meal_plans.id = meal_items.meal_plan_id
    AND dogs.owner_id = auth.uid()
  )
);

CREATE POLICY "Users can insert meal items for their meal plans"
ON meal_items FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM meal_plans
    JOIN dogs ON dogs.id = meal_plans.dog_id
    WHERE meal_plans.id = meal_items.meal_plan_id
    AND dogs.owner_id = auth.uid()
  )
);

CREATE POLICY "Users can update meal items for their meal plans"
ON meal_items FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM meal_plans
    JOIN dogs ON dogs.id = meal_plans.dog_id
    WHERE meal_plans.id = meal_items.meal_plan_id
    AND dogs.owner_id = auth.uid()
  )
);

CREATE POLICY "Users can delete meal items for their meal plans"
ON meal_items FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM meal_plans
    JOIN dogs ON dogs.id = meal_plans.dog_id
    WHERE meal_plans.id = meal_items.meal_plan_id
    AND dogs.owner_id = auth.uid()
  )
);
