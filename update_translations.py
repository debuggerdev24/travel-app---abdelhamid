import json
import os

files = {
    'en': r'c:\Users\shwet\dev\travel-app---abdelhamid\assets\translations\en.json',
    'nl': r'c:\Users\shwet\dev\travel-app---abdelhamid\assets\translations\nl.json',
    'ar': r'c:\Users\shwet\dev\travel-app---abdelhamid\assets\translations\ar.json',
    'fr': r'c:\Users\shwet\dev\travel-app---abdelhamid\assets\translations\fr.json'
}

translations = {
    'en': {
        "No times set": "No times set"
    },
    'nl': {
        "No times set": "Geen tijden ingesteld"
    },
    'ar': {
        "No times set": "لم يتم تحديد أوقات"
    },
    'fr': {
        "No times set": "Aucun horaire défini"
    }
}

for lang, filepath in files.items():
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    for key, val in translations[lang].items():
        if key not in data or True:
            data[key] = val
        
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"Updated {filepath}")
