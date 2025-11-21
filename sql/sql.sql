-- vdl_length SQL Setup

-- 1) Add the 'tail_length' column if it does not exist
ALTER TABLE `characters`
ADD COLUMN IF NOT EXISTS `tail_length` DECIMAL(3,1) NOT NULL DEFAULT 1.0;

-- 2) Ensure all existing rows have a valid default value
UPDATE `characters`
SET `tail_length` = 1.0
WHERE `tail_length` IS NULL;