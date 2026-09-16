#!/usr/bin/env python3
"""Slice composite art sheets into individual assets for Flutter."""

from PIL import Image
import os

ASSETS_DIR = 'assets/art'
OUTPUT_CARDS = f'{ASSETS_DIR}/cards'
OUTPUT_UI = f'{ASSETS_DIR}/ui'
OUTPUT_CAMPAIGN = f'{ASSETS_DIR}/campaign'
OUTPUT_BG = f'{ASSETS_DIR}/backgrounds'

# Create output directories
os.makedirs(OUTPUT_CARDS, exist_ok=True)
os.makedirs(OUTPUT_UI, exist_ok=True)
os.makedirs(OUTPUT_CAMPAIGN, exist_ok=True)
os.makedirs(OUTPUT_BG, exist_ok=True)

def slice_card_sheet(sheet_path, card_names, output_dir):
    """Slice a card sheet with 3 cards horizontally into individual cards."""
    img = Image.open(sheet_path)
    width, height = img.size
    card_width = width // 3
    
    for i, name in enumerate(card_names):
        left = i * card_width
        card_img = img.crop((left, 0, left + card_width, height))
        output_path = os.path.join(output_dir, f'{name}.png')
        card_img.save(output_path, 'PNG')
        print(f'Sliced: {name}')

def slice_resource_icons(sheet_path, output_dir):
    """Slice resource icons (stone, food, gold) from horizontal sheet."""
    img = Image.open(sheet_path)
    width, height = img.size
    icon_width = width // 3
    
    names = ['stone', 'food', 'gold']
    for i, name in enumerate(names):
        left = i * icon_width
        icon_img = img.crop((left, 0, left + icon_width, height))
        output_path = os.path.join(output_dir, f'resource_{name}.png')
        icon_img.save(output_path, 'PNG')
        print(f'Sliced resource: {name}')

def slice_status_indicators(sheet_path, output_dir):
    """Slice status indicators (fire, infantry) from sheet."""
    img = Image.open(sheet_path)
    width, height = img.size
    # Assume 2 indicators side by side
    indicator_width = width // 2
    
    names = ['fire', 'infantry']
    for i, name in enumerate(names):
        left = i * indicator_width
        indicator_img = img.crop((left, 0, left + indicator_width, height))
        output_path = os.path.join(output_dir, f'status_{name}.png')
        indicator_img.save(output_path, 'PNG')
        print(f'Sliced status: {name}')

def slice_campaign_nodes(sheet_path, output_dir):
    """Slice campaign node states from sheet."""
    img = Image.open(sheet_path)
    width, height = img.size
    # Assume 4 states: conquered, current, locked, crown
    node_width = width // 4
    
    names = ['conquered', 'current', 'locked', 'crown']
    for i, name in enumerate(names):
        left = i * node_width
        node_img = img.crop((left, 0, left + node_width, height))
        output_path = os.path.join(output_dir, f'node_{name}.png')
        node_img.save(output_path, 'PNG')
        print(f'Sliced node: {name}')

def slice_result_overlays(sheet_path, output_dir):
    """Slice result overlays (Castle Taken, Siege Repelled, Crowned King)."""
    img = Image.open(sheet_path)
    width, height = img.size
    # Assume 3 overlays horizontally
    overlay_width = width // 3
    
    names = ['castle_taken', 'siege_repelled', 'crowned_king']
    for i, name in enumerate(names):
        left = i * overlay_width
        overlay_img = img.crop((left, 0, left + overlay_width, height))
        output_path = os.path.join(output_dir, f'result_{name}.png')
        overlay_img.save(output_path, 'PNG')
        print(f'Sliced result: {name}')

def copy_single_assets(assets_dir, output_bg):
    """Copy single-asset images to appropriate directories."""
    # Background composites with hash suffixes
    bg_files = {
        'composite-battle-empty_7039.jpg': 'composite-battle-empty.jpg',
        'composite-battle-fire_7f45.jpg': 'composite-battle-fire.jpg',
        'composite-battle-midfight_4cd0.jpg': 'composite-battle-midfight.jpg',
        'stage-mood-calm_81af.jpg': 'stage-mood-calm.jpg',
        'stage-mood-pressure_f3d6.jpg': 'stage-mood-pressure.jpg',
    }
    
    for src_name, dst_name in bg_files.items():
        src = os.path.join(assets_dir, src_name)
        if os.path.exists(src):
            img = Image.open(src)
            dst = os.path.join(output_bg, dst_name)
            img.save(dst)
            print(f'Copied: {dst_name}')
    
    # Campaign map
    src = os.path.join(assets_dir, 'campaign-map_0f2c.jpg')
    if os.path.exists(src):
        img = Image.open(src)
        dst = os.path.join(OUTPUT_CAMPAIGN, 'campaign-map.jpg')
        img.save(dst)
        print('Copied: campaign-map')
    
    # Card back
    src = os.path.join(assets_dir, 'card-back_2e50.jpg')
    if os.path.exists(src):
        img = Image.open(src)
        dst = os.path.join(OUTPUT_CARDS, 'card-back.png')
        img.save(dst, 'PNG')
        print('Copied: card-back')

if __name__ == '__main__':
    print('Slicing card sheets...')
    
    # Attacker cards
    slice_card_sheet(
        f'{ASSETS_DIR}/cards-attacker-fire-volley-fireball_9c72.jpg',
        ['fire', 'volley', 'fireball'],
        OUTPUT_CARDS
    )
    slice_card_sheet(
        f'{ASSETS_DIR}/cards-attacker-infantry-mercenaries-cleanse_d6ba.jpg',
        ['infantry', 'mercenaries', 'cleanse'],
        OUTPUT_CARDS
    )
    
    # Defender cards
    slice_card_sheet(
        f'{ASSETS_DIR}/cards-defender-archers-balista-firearrows_beed.jpg',
        ['archers', 'balista', 'fire_arrows'],
        OUTPUT_CARDS
    )
    slice_card_sheet(
        f'{ASSETS_DIR}/cards-defender-boulders-sabotage-cleanse_a836.jpg',
        ['boulders', 'sabotage', 'cleanse_defender'],
        OUTPUT_CARDS
    )
    
    print('\nSlicing UI elements...')
    slice_resource_icons(f'{ASSETS_DIR}/resource-icons_c541.jpg', OUTPUT_UI)
    slice_status_indicators(f'{ASSETS_DIR}/status-indicators_7fa1.jpg', OUTPUT_UI)
    slice_result_overlays(f'{ASSETS_DIR}/result-overlays-sheet_7131.jpg', OUTPUT_UI)
    
    print('\nSlicing campaign elements...')
    slice_campaign_nodes(f'{ASSETS_DIR}/campaign-node-states_f29b.jpg', OUTPUT_CAMPAIGN)
    
    print('\nCopying single assets...')
    copy_single_assets(ASSETS_DIR, OUTPUT_BG)
    
    print('\n✓ Asset slicing complete!')
