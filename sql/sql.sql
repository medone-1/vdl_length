-- vdl_length SQL Setup

-- 1) Adds the 'tail_length' column if not present
ALTER TABLE `characters`
ADD COLUMN `tail_length` FLOAT DEFAULT 1.0;

-- 2) Ensures all existing rows have a valid default value
UPDATE `characters`
SET `tail_length` = 1.0
WHERE `tail_length` IS NULL;
