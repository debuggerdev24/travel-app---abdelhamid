import re
import os

dirs_to_scan = ['lib/features', 'lib/core/widgets']
pattern = re.compile(r'const\s+(Text|AppText)\s*\(([^)]*\.tr\(\))')

# Sometimes the 'const ' is on a parent widget. E.g. `const Center(child: Text("...".tr()))`
# Removing parent consts is trickier. Let's look at `analyze_output.txt` to properly fix it.

with open('analyze_output.txt', 'r', encoding='utf-16') as f:
    lines = f.readlines()

changes = {}

for line in lines:
    if "error - Methods can't be invoked in constant expressions" in line:
        parts = line.strip().split(' - ')
        if len(parts) >= 3:
            file_info = parts[-2]
            file_parts = file_info.split(':')
            if len(file_parts) >= 3:
                col = int(file_parts[-1])
                line_num = int(file_parts[-2])
                filepath = ':'.join(file_parts[:-2]).strip()
                
                if filepath not in changes:
                    changes[filepath] = []
                changes[filepath].append((line_num, col))

for filepath, edits in changes.items():
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            file_lines = f.readlines()
            
        for line_num, col in edits:
            idx = line_num - 1 # 0-indexed
            
            # search backwards up to 10 lines to find the nearest `const `
            for offset in range(10):
                if idx - offset >= 0:
                    if 'const ' in file_lines[idx - offset]:
                        # remove the last occurrence of 'const ' on this line
                        parts = file_lines[idx - offset].rsplit('const ', 1)
                        file_lines[idx - offset] = ''.join(parts)
                        break
                    
        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(file_lines)
    except Exception as e:
        pass

print(f"Fixed {len(changes)} files.")
