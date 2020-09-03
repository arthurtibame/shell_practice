import json
import os
import sys

def read_all_json(path):

    all_files = os.listdir(path)
    full_path_files = [f"{path}/{f}" for f in all_files]    
    errors = 0
    for path in full_path_files:
        try:
            with open (path, 'r', encoding='utf-8') as f1:
                content = f1.read()
            content = f"[{content[:-2]}]"
            content = json.loads(content)
            with open(path, 'w', encoding='utf-8') as f2:
                f2.write(json.dumps(content))
        except:
            print("ERROR!:",path, "Please the file type")
            errors+=1
    if errors==0:
        return "Complete json format !"
    return f"ERRORS: {errors}"

    
    

     

if __name__ == "__main__":
    path=sys.argv[1]
    json_content= read_all_json(str(path))
    print(json_content)
    
