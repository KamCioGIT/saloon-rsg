# RSG Saloon Premium v2.0

A comprehensive, premium saloon management system for RedM servers using RSGCore framework. Features table service with prop placement, advanced crafting, financial tracking, drunk effects, billing, and employee management.

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![Framework](https://img.shields.io/badge/framework-RSGCore-green)
![Game](https://img.shields.io/badge/game-RedM-red)

---

## ✨ Features

### 🍺 Shop & Sales
- Customer-facing shop with categorized items
- Real-time stock tracking and pricing
- Optional tipping system for employees

### 🍽️ Table Service (NEW in v2.0)
- **Prop Placer**: Place drinks and food directly on tables
- **Custom Plates**: Build meals with main dish + side dish + plate style
- **Pickup System**: Customers interact with placed items to consume
- **Networked**: All players see placed items in real-time

### 🔨 Crafting System
- 15+ recipes (drinks & food)
- Yield bonuses (craft 1, get 2+)
- Visual ingredient checking
- ox_lib progress bar with animations

### 📦 Storage Management
- Private storage for crafted items
- Refill shop with custom pricing
- Grade-based access control

### 💰 Financial System
- Cashbox with balance tracking
- Transaction history logging
- Daily sales statistics
- Secure withdrawal system for managers

### 💵 Billing System (NEW in v2.0)
- Create and send bills to customers
- Bill tracking per player
- Payment goes directly to cashbox

### 🍺 Drunk Effects (NEW in v2.0)
- Progressive intoxication levels
- Camera shake and visual effects
- Movement impairment
- Ragdoll at max drunk level

### 👥 Employee Management (NEW in v2.0)
- In-game hire/fire system
- Grade-based permissions (0-3)
- Employee statistics tracking

### 🎵 Jukebox
- Ambient music playback
- Track selection
- Volume control

### 🧹 Work Animations (NEW in v2.0)
- Glass cleaning animation
- Table wiping animation
- Drink serving animation

### 🎹 Piano System (NEW in v2.0)
- Play piano at 8 saloon locations
- rsg-target (third eye) interaction
- Male/female character animations
- Random piano scenarios (upperclass, riverboat, sketchy)

### 📻 Phonograph System (NEW in v2.0)
- Place phonograph props at saloons
- Play music from YouTube/URL (requires xsound)
- Volume controls (up/down)
- Job-based: Only saloon employees can place (1 per saloon)
- Any saloon employee can remove

---

## 📋 Permission Grades

| Grade | Role | Permissions |
|-------|------|-------------|
| 0 | Helper | Crafting only |
| 1 | Bartender | + Refill shop, table service |
| 2 | Manager | + Cashbox access, billing |
| 3 | Owner | + Hire/fire employees |

---

## 📦 Dependencies

| Dependency | Link |
|------------|------|
| `rsg-core` | [GitHub](https://github.com/Rexshack-RedM/rsg-core) |
| `ox_lib` | [GitHub](https://github.com/overextended/ox_lib) |
| `oxmysql` | [GitHub](https://github.com/overextended/oxmysql) |
| `rsg-target` | [GitHub](https://github.com/Rexshack-RedM/rsg-target) |
| `rsg-inventory` | For item images |

---

## 🚀 Installation

### Step 1: Database Setup

Run the SQL file in your MySQL database:

```sql
-- In MySQL console or phpMyAdmin:
source installation/saloon_premium.sql;
```

**Tables Created:**
- `saloon_premium_stock` - Shop inventory
- `saloon_premium_storage` - Private crafted items
- `saloon_premium_cashbox` - Earnings balance
- `saloon_premium_transactions` - Sale/withdrawal logs
- `saloon_premium_employees` - Employee stats
- `saloon_premium_bills` - Customer invoices

### Step 2: Add to server.cfg

```cfg
# Load dependencies first
ensure rsg-core
ensure ox_lib
ensure oxmysql
ensure rsg-target
ensure rsg-inventory

# Then load this resource
ensure rsg-saloon-premium
```

### Step 3: Add Saloon Jobs to RSGCore

Copy the contents of `installation/jobs.lua` into your `rsg-core/shared/jobs.lua` file.

**Jobs included:**
- `valsaloontender` - Valentine Saloon
- `blasaloontender` - Blackwater Saloon
- `rhosaloontender` - Rhodes Saloon
- `stdenissaloontender1` - Saint Denis Saloon
- `stdenissaloontender2` - Saint Denis Saloon 2
- `vansaloontender` - Van Horn Saloon
- `armsaloontender` - Armadillo Saloon
- `tumsaloontender` - Tumbleweed Saloon

### Step 4: Add Items to RSGCore

Copy the contents of `installation/items.lua` into your `rsg-core/shared/items.lua` file.

**Items included:**
- 16 Drinks (beer, whiskey, vodka, tequila, rum, wine, coffee, etc.)
- 6 Food items (stew, steak, bread, soup, pie, roasted meat)
- 13 Crafting ingredients
- 1 Phonograph equipment

### Step 5: Add Item Images

Copy item images (`.png` format) to:
- `rsg-inventory/html/images/` (for inventory display)
- `rsg-saloon-premium/html/images/` (for UI display)

---

## ⚙️ Configuration

### config.lua Settings

| Setting | Description | Default |
|---------|-------------|---------|
| `Config.Debug` | Enable debug messages | `false` |
| `Config.Keybind` | Key to open menu | `'J'` |
| `Config.StorageMaxWeight` | Max storage weight | `500000` |
| `Config.StorageMaxSlots` | Max storage slots | `100` |
| `Config.TipsEnabled` | Allow tipping | `true` |
| `Config.JukeboxEnabled` | Enable jukebox | `true` |
| `Config.DrunkEffects.enabled` | Enable drunk effects | `true` |

### Adding/Removing Saloons

Edit `Config.Saloons` in `config.lua`:

```lua
['yoursaloonid'] = {
    name = 'Your Saloon Name',
    coords = vector3(x, y, z),
    showBlip = true,
    grades = {
        crafting = 0,
        refill = 1,
        cashbox = 2,
        employees = 3,
    },
    points = {
        bar = vector3(x, y, z),
        storage = vector3(x, y, z),
        jukebox = vector3(x, y, z),
    }
},
```

### Adding Custom Recipes

Edit `Config.Recipes`:

```lua
{
    item = 'itemname',
    label = 'Display Name',
    category = 'drinks', -- or 'food'
    time = 5000, -- milliseconds
    yield = 2, -- items produced
    image = 'itemname.png',
    requirements = {
        { item = 'ingredient1', amount = 1 },
        { item = 'ingredient2', amount = 2 },
    }
},
```

---

## 🎮 Usage Guide

### For Employees

1. **Access Menu**: Use rsg-target on the bar counter
2. **Crafting Tab**: Select recipe → Start Crafting (uses your ingredients)
3. **Storage Tab**: View crafted items
4. **Refill Tab**: Move items from storage to shop with custom pricing
5. **Cashbox Tab** (Grade 2+): View balance, transactions, withdraw funds
6. **Table Service**: Use "Serve" menu to place drinks/food on tables

### For Customers

1. **Access Menu**: Use rsg-target on bar counter
2. **Shop Tab**: Browse available items by category
3. **Purchase**: Select item, quantity, optional tip
4. **Table Pickup**: Interact with items placed on tables to consume

### Table Service (Employees)

1. Select "Serve Drinks" or "Serve Food" from menu
2. A ghost prop appears following your cursor
3. Use **Q/E** to rotate
4. Press **E (hold)** to place
5. Press **Backspace (hold)** to cancel
6. Customers can then interact with placed items

---

## 🗂️ File Structure

```
rsg-saloon-premium/
├── client/
│   ├── main.lua          # Core client, NUI, targets
│   ├── crafting.lua      # Crafting animations
│   ├── shop.lua          # Shop callbacks
│   ├── jukebox.lua       # Music system
│   ├── propplacer.lua    # Table placement [v2.0]
│   ├── consumption.lua   # Eating/drinking anims [v2.0]
│   ├── drunk.lua         # Drunk effects [v2.0]
│   ├── billing.lua       # Billing UI [v2.0]
│   ├── animations.lua    # Work animations [v2.0]
│   └── piano.lua         # Piano system [v2.0]
├── server/
│   ├── main.lua          # Core server, callbacks
│   ├── crafting.lua      # Crafting logic
│   ├── shop.lua          # Shop/sales logic
│   ├── storage.lua       # Storage management
│   ├── cashbox.lua       # Financial system
│   ├── placedprops.lua   # Networked props [v2.0]
│   ├── billing.lua       # Bill processing [v2.0]
│   ├── employees.lua     # Hire/fire [v2.0]
│   └── piano.lua         # Piano server [v2.0]
├── html/
│   ├── index.html
│   ├── css/
│   │   ├── main.css
│   │   ├── animations.css
│   │   └── components.css
│   ├── js/
│   │   └── app.js
│   ├── images/           # Item images
│   └── sounds/           # Jukebox tracks
├── installation/
│   ├── saloon_premium.sql
│   ├── jobs.lua          # Copy to rsg-core
│   └── items.lua         # Copy to rsg-core
├── locales/
│   └── en.lua
├── config.lua
├── fxmanifest.lua
└── README.md
```

---

## 🔧 Troubleshooting

### Menu not opening
- Ensure rsg-target is installed and working
- Check if player has the correct job assigned
- Verify coordinates in Config.Saloons match your map

### Items not appearing in shop
- Run the SQL file to create tables
- Craft items and refill shop first
- Check database for entries in `saloon_premium_stock`

### Crafting fails
- Ensure ingredients are in player's inventory
- Verify item names match in Config.Recipes and rsg-core/shared/items.lua

### Drunk effects not working
- Check `Config.DrunkEffects.enabled = true`
- Ensure you're drinking alcoholic items from ServableDrinks list

---

## 📝 Changelog

### v2.0.0
- ✨ Added table service with prop placer
- ✨ Added custom plate assembly system
- ✨ Added eating/drinking animations with props
- ✨ Added progressive drunk effects
- ✨ Added billing/invoicing system
- ✨ Added employee hire/fire management
- ✨ Added work animations (clean glass, clean table)
- 🎹 Added piano system with rsg-target (8 locations)
- 📦 26 servable drinks with alcohol levels
- 📦 11 servable food items
- 📦 9 plate main dishes + side dishes

### v1.0.0
- Initial release with crafting, shop, cashbox, jukebox

---

## 📄 License

MIT License - Free for personal and commercial use.

---

## 👤 Credits

**Author:** devchacha

**Framework:** RSGCore for RedM

