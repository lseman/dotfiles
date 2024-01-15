import argparse
import subprocess
import os

def generate_diff(path_a, path_b, input_file, output_file):
    with open(input_file, 'r') as file, open(output_file, "w") as outfile:
        for line in file:
            file_path = line.strip()
            diff_command = f"diff -uNr {path_a}/{file_path} {path_b}/{file_path}"
            subprocess.run(diff_command, shell=True, stdout=outfile, stderr=subprocess.STDOUT)

def apply_patch(path_a, patch_file, output_dir):
    apply_command = f"patch -d {path_a} -p1 < {patch_file}"
    subprocess.run(apply_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)


def copy_files(input_file, path_b, output_dir):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    with open(input_file, 'r') as file:
        for line in file:
            file_path = line.strip()
            dest_dir = os.path.join(output_dir, os.path.dirname(file_path))
            os.makedirs(dest_dir, exist_ok=True)
            cp_command = f"cp {path_b}/{file_path} {dest_dir}"
            subprocess.run(cp_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

def copy_module_files(path_b, module, input_file, output_dir):
    for root, dirs, files in os.walk(os.path.join(path_b, module)):
        for file in files:
            full_path = os.path.join(root, file)
            relative_path = os.path.relpath(full_path, path_b)
            if relative_path not in input_file:
                dest_path = os.path.join(output_dir, relative_path)
                os.makedirs(os.path.dirname(dest_path), exist_ok=True)
                cp_command = f"cp '{full_path}' '{dest_path}'"
                subprocess.run(cp_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

def create_dkms_conf(name, version, module_location, output_dir):
    dkms_conf = f'''# Use environment variables or default values
PACKAGE_NAME="${{PACKAGE_NAME:-{name}}}"
PACKAGE_VERSION="${{PACKAGE_VERSION:-{version}}}"
KERNEL_VERSION="${{KERNEL_VERSION:-$(uname -r)}}"
SRC_DIR="/usr/src/${{PACKAGE_NAME}}-${{PACKAGE_VERSION}}"
BUILD_DIR="/usr/lib/modules/${{KERNEL_VERSION}}/build"
DEST_DIR="/updates/{module_location}"

CLEAN="make clean"
MAKE[0]="make NOSTDINC_FLAGS='-I${{SRC_DIR}}/include' -C ${{BUILD_DIR}} M=${{SRC_DIR}}/{module_location} -j$(nproc)"
BUILT_MODULE_NAME[0]="${{PACKAGE_NAME}}"
BUILT_MODULE_LOCATION[0]="{module_location}"
DEST_MODULE_LOCATION[0]="${{DEST_DIR}}"
AUTOINSTALL="no"
'''
    dkms_path = f"/usr/src/{name}-{version}"
    if not os.path.exists(dkms_path):
        os.makedirs(dkms_path)
    cp_command = f"cp -r {output_dir}/* {dkms_path}"
    subprocess.run(cp_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    with open(f"{dkms_path}/dkms.conf", "w") as file:
        file.write(dkms_conf)

def copy_modified_files(path_a, patch_file, output_dir):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    with open(patch_file, 'r') as file:
        for line in file:
            if line.startswith('+++'):
                # consider patch in the form -p1
                file_path = line.strip()[6:]
                dest_dir = os.path.join(output_dir, os.path.dirname(file_path))
                os.makedirs(dest_dir, exist_ok=True)
                cp_command = f"cp {path_a}/{file_path} {dest_dir}"
                subprocess.run(cp_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

def main():
    epilog_text = """
    Developed by Laio O. Seman
    Contact: laio [at] ieee.org

    Usage Examples:
    1. Diff Mode: python script.py --mode diff --path_a /path/to/original_kernel --path_b /path/to/modified_kernel
    2. Patch Mode: python script.py --mode patch --path_a /path/to/kernel --patch_file /path/to/patch
    """
    parser = argparse.ArgumentParser(description='Kernel Patch Generator and Copier', epilog=epilog_text, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--mode', choices=['diff', 'patch'], required=True, help='Mode of operation: "diff" or "patch"')
    parser.add_argument('--path_a', required=True, help='Path to original kernel source or kernel source for patching')
    parser.add_argument('--path_b', help='Path to modified kernel source (for diff mode)')
    parser.add_argument('--patch_file', help='Path to patch file (for patch mode)')
    parser.add_argument('--input_file', default='modified_files_list.txt', help='File listing modified files (for diff mode)')
    parser.add_argument('--output_dir', default='output_patch_kernel', help='Output directory for patches and files')
    parser.add_argument('--module', default='fs/f2fs', help='Kernel module path')
    parser.add_argument('--name', default='f2fs', help='Name for dkms package')
    parser.add_argument('--version', default='6.8', help='Version for dkms package')
    args = parser.parse_args()


    if args.mode == 'diff':
        if not args.path_b:
            parser.error('path_b is required for diff mode')
        if not os.path.isfile(args.input_file):
            print(f"Input file not found: {args.input_file}")
            exit(1)
        output_file = "combined_diff.patch"
        generate_diff(args.path_a, args.path_b, args.input_file, output_file)
        print("Diff file generated:", output_file)
        copy_files(args.input_file, args.path_b, args.output_dir)
    elif args.mode == 'patch':
        if not args.patch_file:
            parser.error('patch_file is required for patch mode')
        
        # create output dir if not exists
        if not os.path.exists(args.output_dir):
            os.makedirs(args.output_dir)

        apply_patch(args.path_a, args.patch_file, args.output_dir)
        copy_modified_files(args.path_a, args.patch_file, args.output_dir)

    print("Files copied to output dir:", args.output_dir)
    copy_module_files(args.path_a if args.mode == 'patch' else args.path_b, args.module, args.input_file, args.output_dir)
    create_dkms_conf(args.name, args.version, args.module, args.output_dir)
    print(f"Files and dkms.conf copied to /usr/src/{args.name}-{args.version}")

if __name__ == "__main__":
    main()
