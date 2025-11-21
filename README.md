# vdl_length – Persistent Character Length Scale (RedM VORP)

A clean and reliable script that stores and applies each character's **length (scale)** permanently.  
The value is saved in the database and automatically re-applied on every spawn, model change, or reconnect.

- Framework: **VORP Core**
- Database: **oxmysql**
- Fully Persistent
- Admin & Player Commands
- 100% Safe & Clean

---

## 🚀 Features

✔ Permanent character scaling (per character, not per player)  
✔ Automatically applies after spawn and on ped model change  
✔ Frame-based sync to prevent game resets  
✔ Admin Steam Hex whitelist  
✔ Player-friendly `/refreshped` reload command  
✔ Clean SQL setup  
✔ Extremely lightweight & optimized  

---

## 📦 Requirements

- **vorp_core**
- **oxmysql**
- RedM (latest version)

---

## 🔧 Installation

1️⃣ Place the resource in your server: `resources/vdl_length`
2️⃣ Add this to your `server.cfg`: `ensure vdl_length`
3️⃣ Import the SQL into your database:
```sql
-- vdl_length SQL Setup

-- 1) Add the 'tail_length' column if it does not exist
ALTER TABLE `characters`
ADD COLUMN IF NOT EXISTS `tail_length` DECIMAL(3,1) NOT NULL DEFAULT 1.0;

-- 2) Ensure all existing rows have a valid default value
UPDATE `characters`
SET `tail_length` = 1.0
WHERE `tail_length` IS NULL;
```
4️⃣ Edit config.lua:
```lua
Config.Admins = {
    "steam:11000015af9467a" -- change to your steam hex
}
```



