import os
import re
import json

dirs_to_scan = ['lib/features', 'lib/core/widgets']
extracted = set()

# Regex to find: Text("..."), Text('...'), AppText(text: "..."), text: "...", label: "...", hintText: "..."
# We will capture:
# Group 1: The prefix (e.g. `Text(` or `AppText(text: ` or `label: `)
# Group 2: The quote char (`"` or `'`)
# Group 3: The text inside quotes (must not contain `$` to avoid interpolation, or quotes)
pattern = re.compile(r'((?<!\w)Text\(\s*|AppText\(\s*text:\s*|(?<!\w)text:\s*|(?<!\w)label:\s*|(?<!\w)hintText:\s*)(["\'])([^"\$\']+?)\2(?!\.tr\(\))')

def replacer(match):
    prefix = match.group(1)
    quote = match.group(2)
    text = match.group(3)
    
    # Skip paths, empty strings, or things with no letters
    if text.strip() == '' or '/' in text or '.png' in text or '.jpg' in text or '.svg' in text or not any(c.isalpha() for c in text):
        return match.group(0)
        
    extracted.add(text)
    return f'{prefix}{quote}{text}{quote}.tr()'

files_modified = 0

for root_dir in dirs_to_scan:
    if not os.path.exists(root_dir):
        continue
    for dirpath, _, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename.endswith('.dart'):
                filepath = os.path.join(dirpath, filename)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                new_content = pattern.sub(replacer, content)
                
                if new_content != content:
                    # Add import if missing
                    if 'easy_localization.dart' not in new_content:
                        import_stmt = "import 'package:easy_localization/easy_localization.dart';\n"
                        # Insert after the first import or at the top
                        if 'import ' in new_content:
                            new_content = new_content.replace('import ', import_stmt + 'import ', 1)
                        else:
                            new_content = import_stmt + new_content
                            
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    files_modified += 1

# Export the extracted strings
output_data = {text: text for text in extracted}
with open('extracted_strings.json', 'w', encoding='utf-8') as f:
    json.dump(output_data, f, indent=2, ensure_ascii=False)

print(f"Modified {files_modified} files. Extracted {len(extracted)} unique strings.")
