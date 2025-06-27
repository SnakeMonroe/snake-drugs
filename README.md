# Snake Drugs - Drug System for RSG v1.0.0

## 📦 Description

A modular and configurable drug system for RedM that enables players to gather, process, use, and sell drugs like Opium. Designed for easy expansion and seamless integration with major frameworks.

---

## 🚀 Features

- 🔬 Ingredient-based drug crafting  
- 🧪 Configurable processing zones with `ox_target`  
- 💊 Drug usage with effects - find out what these will do to your body  
- 💸 Drug selling system with cooldowns and NPC interaction  
- 🚨 Law enforcement alerts with blips and notifications  
- ⚙️ Tool degradation and durability system  

---

## 🛠️ Configuration

All settings are managed in `config.lua`.

### 🔹 `Config.Drugs`

Defines properties of each drug:

- **`label`** — Display name  
- **`ingredients`** — Required items and amounts (e.g., `{prairiepoppy = 3}`)  
- **`output`** — Produced item and quantity  
- **`enabled`** — Enable or disable the drug  
- **`sell`** — Selling options:  
  - `enabled` — Allow selling  
  - `price` — Price per unit  
  - `lawAlertChance` — Chance to alert law enforcement (0.0 to 1.0)  
  - `minSellAmount`, `maxSellAmount` — Randomized amount per sale  
- **`locations`** — Coordinates for processing zones (`vector3(...)`)  

### 🔹 `Config.Tools`

Tool durability and degradation settings:

- `degrade` — Enable tool wear  
- `loss` — Durability lost per use  
- `breakAt` — Threshold to break the tool  
- `defaultQuality` — Starting durability  

### 🔹 `Config.Selling`

Global selling settings:

- `enabled` — Master toggle for selling system  
- `interactionDistance` — Radius to detect NPCs  
- `sellCooldown` — Cooldown between sales (ms)  
- `maxNPCsNearby` — Max NPCs to consider  
- `notifyPosition` — UI notification position  
- `sellInteractionIcon` — Icon for selling interaction  

### 🔹 `Config.LawAlerts`

Law enforcement alert behavior:

- `enabled` — Master toggle for alerts  
- `notify` — Show notification via `ox_lib`  
- `blip` — Display blip at alert location  
- `blipTime` — Blip duration in seconds  
- `blipSprite`, `blipColor` — Customize blip appearance  
- `notifyType` — Notification style (`inform`, `error`, etc.)  
- `lawAlertMessage` — Default message for law alerts  

---

## 👤 Client Side

- Creates processing zones with `ox_target`  
- Handles `/drugsell` command to toggle selling mode  
- Detects nearby NPCs and manages selling interactions  
- Applies drug usage effects including animations, healing, stumble, movement slow, and screen effects  
- Displays notifications and law enforcement alert blips  

---

## 🧠 Server Side

- Validates processing and manages item exchanges  
- Controls selling logic and cooldowns  
- Triggers law enforcement alerts  
- Manages item durability and tool quality  

---

## 📚 Usage

1. Collect required ingredients.  
2. Visit processing locations (`Config.Drugs[*].locations`).  
3. Interact to process drugs.  
4. Use `/drugsell` to start selling to nearby NPCs.  
5. Use drugs to experience effects like healing, stumble, and visual overlays.  
6. NPCs buy drugs in randomized amounts with cooldowns.  
7. Sales may trigger law enforcement alerts (if enabled).  

---

## 🔗 Dependencies

Make sure the following resources are installed and running before `snake-drugs`:

- [`ox_lib`](https://overextended.dev/)  
- [`ox_target`](https://overextended.dev/)  
- `rsg-inventory`  
- `rsg-core`  

---

## 🧰 Installation

1. Place the `snake-drugs` folder inside your `resources` directory.  
2. Add `ensure snake-drugs` to your `server.cfg`.  
3. Configure settings via `config.lua`.  
4. Verify all dependencies are running properly.  

---

## 👑 Credits

Developed by **[Snake]**

---

## 📄 License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).
