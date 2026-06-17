import json
import os
import time
from deep_translator import GoogleTranslator

languages = ['en', 'nl', 'fr', 'ar']

with open('extracted_strings.json', 'r', encoding='utf-8') as f:
    extracted = json.load(f)

for lang_code in languages:
    print(f"Processing language: {lang_code}")
    filepath = f'assets/translations/{lang_code}.json'
    
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            try:
                data = json.load(f)
            except:
                data = {}
    else:
        data = {}
        
    translator = GoogleTranslator(source='en', target=lang_code) if lang_code != 'en' else None
    
    count = 0
    for key in extracted:
        if key not in data:
            if lang_code == 'en':
                data[key] = key
            else:
                try:
                    translated = translator.translate(key)
                    if translated:
                        data[key] = translated
                    else:
                        data[key] = key
                    time.sleep(0.05) # prevent rate limit
                except Exception as e:
                    print(f"Error translating {key} to {lang_code}: {e}")
                    data[key] = key
            count += 1
            if count % 50 == 0:
                print(f"  Translated {count}/{len(extracted)} strings...")
    
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

print("Translation complete!")
