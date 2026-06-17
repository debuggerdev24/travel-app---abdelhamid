import json
import os
import concurrent.futures
from deep_translator import GoogleTranslator

languages = ['nl', 'fr', 'ar']

with open('extracted_strings.json', 'r', encoding='utf-8') as f:
    extracted = json.load(f)

# Ensure English is populated first since it just copies the keys
en_path = 'assets/translations/en.json'
with open(en_path, 'r', encoding='utf-8') as f:
    try:
        en_data = json.load(f)
    except:
        en_data = {}
        
for key in extracted:
    if key not in en_data:
        en_data[key] = key
        
with open(en_path, 'w', encoding='utf-8') as f:
    json.dump(en_data, f, indent=2, ensure_ascii=False)

def translate_key(lang, key):
    translator = GoogleTranslator(source='en', target=lang)
    try:
        res = translator.translate(key)
        return key, res if res else key
    except Exception as e:
        print(f"Error on {key}: {e}")
        return key, key

for lang_code in languages:
    print(f"Translating for {lang_code}...")
    filepath = f'assets/translations/{lang_code}.json'
    
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            try:
                data = json.load(f)
            except:
                data = {}
    else:
        data = {}
    
    keys_to_translate = [k for k in extracted if k not in data]
    
    if not keys_to_translate:
        print(f"Nothing to translate for {lang_code}.")
        continue
        
    print(f"Translating {len(keys_to_translate)} keys concurrently...")
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=20) as executor:
        futures = {executor.submit(translate_key, lang_code, k): k for k in keys_to_translate}
        count = 0
        for future in concurrent.futures.as_completed(futures):
            k, v = future.result()
            data[k] = v
            count += 1
            if count % 50 == 0:
                print(f"  {count}/{len(keys_to_translate)} done.")
                
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        
print("All done!")
