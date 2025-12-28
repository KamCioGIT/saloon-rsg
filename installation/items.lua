-- ============================================================================
-- RSG SALOON PREMIUM - ITEMS
-- Copy this content to your rsg-core/shared/items.lua file
-- ============================================================================

-- =====================================
-- DRINKS (Craftable & Sellable)
-- =====================================
['beer'] = {['name'] = 'beer', ['label'] = 'Beer', ['weight'] = 500, ['type'] = 'item', ['image'] = 'beer.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'A refreshing cold beer'},
['whiskey'] = {['name'] = 'whiskey', ['label'] = 'Whiskey', ['weight'] = 500, ['type'] = 'item', ['image'] = 'whiskey.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Fine aged whiskey'},
['vodka'] = {['name'] = 'vodka', ['label'] = 'Vodka', ['weight'] = 500, ['type'] = 'item', ['image'] = 'vodka.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Strong potato vodka'},
['tequila'] = {['name'] = 'tequila', ['label'] = 'Tequila', ['weight'] = 500, ['type'] = 'item', ['image'] = 'tequila.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Mexican tequila'},
['rum'] = {['name'] = 'rum', ['label'] = 'Rum', ['weight'] = 500, ['type'] = 'item', ['image'] = 'rum.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Caribbean rum'},
['wine'] = {['name'] = 'wine', ['label'] = 'Red Wine', ['weight'] = 500, ['type'] = 'item', ['image'] = 'wine.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Fine red wine'},
['coffee'] = {['name'] = 'coffee', ['label'] = 'Coffee', ['weight'] = 300, ['type'] = 'item', ['image'] = 'coffee.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Hot black coffee'},
['lemonade'] = {['name'] = 'lemonade', ['label'] = 'Lemonade', ['weight'] = 400, ['type'] = 'item', ['image'] = 'lemonade.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Fresh squeezed lemonade'},
['gin'] = {['name'] = 'gin', ['label'] = 'Gin', ['weight'] = 500, ['type'] = 'item', ['image'] = 'gin.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Botanical spirit'},
['brandy'] = {['name'] = 'brandy', ['label'] = 'Brandy', ['weight'] = 500, ['type'] = 'item', ['image'] = 'brandy.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Distilled wine'},
['cider'] = {['name'] = 'cider', ['label'] = 'Cider', ['weight'] = 500, ['type'] = 'item', ['image'] = 'cider.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Apple cider'},
['sarsaparilla'] = {['name'] = 'sarsaparilla', ['label'] = 'Sarsaparilla', ['weight'] = 500, ['type'] = 'item', ['image'] = 'sarsaparilla.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Root beer'},
['tea'] = {['name'] = 'tea', ['label'] = 'Tea', ['weight'] = 200, ['type'] = 'item', ['image'] = 'tea.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Hot tea'},
['hot_chocolate'] = {['name'] = 'hot_chocolate', ['label'] = 'Hot Chocolate', ['weight'] = 200, ['type'] = 'item', ['image'] = 'hot_chocolate.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Sweet hot cocoa'},
['mulled_wine'] = {['name'] = 'mulled_wine', ['label'] = 'Mulled Wine', ['weight'] = 300, ['type'] = 'item', ['image'] = 'mulled_wine.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Spiced warm wine'},
['herbal_tea'] = {['name'] = 'herbal_tea', ['label'] = 'Herbal Tea', ['weight'] = 200, ['type'] = 'item', ['image'] = 'herbal_tea.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Healthy herbal tea'},

-- =====================================
-- FOOD (Craftable & Sellable)
-- =====================================
['stew'] = {['name'] = 'stew', ['label'] = 'Meat Stew', ['weight'] = 800, ['type'] = 'item', ['image'] = 'stew.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Hearty meat stew'},
['steak'] = {['name'] = 'steak', ['label'] = 'Fried Steak', ['weight'] = 600, ['type'] = 'item', ['image'] = 'steak.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Perfectly fried steak'},
['bread'] = {['name'] = 'bread', ['label'] = 'Fresh Bread', ['weight'] = 300, ['type'] = 'item', ['image'] = 'bread.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Freshly baked bread'},
['soup'] = {['name'] = 'soup', ['label'] = 'Vegetable Soup', ['weight'] = 500, ['type'] = 'item', ['image'] = 'soup.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Warm vegetable soup'},
['pie'] = {['name'] = 'pie', ['label'] = 'Apple Pie', ['weight'] = 500, ['type'] = 'item', ['image'] = 'pie.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Homemade apple pie'},
['roastedmeat'] = {['name'] = 'roastedmeat', ['label'] = 'Roasted Meat', ['weight'] = 700, ['type'] = 'item', ['image'] = 'roastedmeat.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Perfectly roasted meat'},

-- =====================================
-- CRAFTING INGREDIENTS
-- =====================================
['wheat'] = {['name'] = 'wheat', ['label'] = 'Wheat', ['weight'] = 100, ['type'] = 'item', ['image'] = 'wheat.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'Fresh wheat grain'},
['water'] = {['name'] = 'water', ['label'] = 'Water', ['weight'] = 200, ['type'] = 'item', ['image'] = 'water.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Clean water'},
['corn'] = {['name'] = 'corn', ['label'] = 'Corn', ['weight'] = 100, ['type'] = 'item', ['image'] = 'corn.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'Fresh corn'},
['potato'] = {['name'] = 'potato', ['label'] = 'Potato', ['weight'] = 150, ['type'] = 'item', ['image'] = 'potato.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'Fresh potato'},
['sugar'] = {['name'] = 'sugar', ['label'] = 'Sugar', ['weight'] = 100, ['type'] = 'item', ['image'] = 'sugar.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'Refined sugar'},
['cactus'] = {['name'] = 'cactus', ['label'] = 'Cactus', ['weight'] = 200, ['type'] = 'item', ['image'] = 'cactus.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'Desert cactus'},
['grape'] = {['name'] = 'grape', ['label'] = 'Grapes', ['weight'] = 150, ['type'] = 'item', ['image'] = 'grape.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Fresh grapes'},
['coffeebeans'] = {['name'] = 'coffeebeans', ['label'] = 'Coffee Beans', ['weight'] = 100, ['type'] = 'item', ['image'] = 'coffeebeans.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'Roasted coffee beans'},
['lemon'] = {['name'] = 'lemon', ['label'] = 'Lemon', ['weight'] = 100, ['type'] = 'item', ['image'] = 'lemon.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Fresh lemon'},
['meat'] = {['name'] = 'meat', ['label'] = 'Raw Meat', ['weight'] = 500, ['type'] = 'item', ['image'] = 'meat.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'Raw meat'},
['carrot'] = {['name'] = 'carrot', ['label'] = 'Carrot', ['weight'] = 100, ['type'] = 'item', ['image'] = 'carrot.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Fresh carrot'},
['herb'] = {['name'] = 'herb', ['label'] = 'Herbs', ['weight'] = 50, ['type'] = 'item', ['image'] = 'herb.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'Cooking herbs'},
['apple'] = {['name'] = 'apple', ['label'] = 'Apple', ['weight'] = 100, ['type'] = 'item', ['image'] = 'apple.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Fresh apple'},

-- =====================================
-- SALOON EQUIPMENT
-- =====================================
['phonograph'] = {['name'] = 'phonograph', ['label'] = 'Phonograph', ['weight'] = 5000, ['type'] = 'item', ['image'] = 'phonograph.png', ['unique'] = true, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'A music player for saloons'},
