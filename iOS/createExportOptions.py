#!/usr/bin/env python3

import sys
import os
import os.path
import plistlib
from argparse import ArgumentParser

modes = ['Development', 'AdHoc', 'Release']

def main(args):
    output = args.output
    if args.create_directory:
        output = create_directory(output)
    bundle_id = args.bundle_id
    for mode in modes:
        data = createExportOptions(bundle_id, mode)
        outputDir = os.path.abspath(output)
        outputFile = "{}/{}.plist".format(outputDir, mode)
        try:
            outputPlist(data, outputFile)
        except Exception as e:
            print('Error: {}'.format(e))
        else:
            print("output: {}".format(outputFile))

def createExportOptions(bundle_id, mode):
    if mode == modes[0]:
        data = {'method': 'development', 'uploadSymbols': True}
    elif mode == modes[1]:
        data = {'method': 'ad-hoc'}
    elif mode == modes[2]:
        data = {'method': 'app-store', 'uploadBitcode': True}
    else:
        exit(1)
    data['provisioningProfiles'] = {bundle_id: 'TODO: Input Provisioning Profile'}
    return data

def create_directory(output):
    dir_name = 'ExportOptions'
    dir_path = "{}/{}".format(output, dir_name)
    directory = os.path.abspath(dir_path)
    if not os.path.exists(directory):
        print("create {}".format(directory))
        os.makedirs(directory)
    return dir_path

def outputPlist(data, dest):
    f = open(dest, 'wb')
    try:
        plistlib.dump(data, f)
    except Exception as e:
        os.remove(dest)
        raise e
    finally:
        f.close()
    
def parse():
    argparser = ArgumentParser()
    argparser.add_argument('-o', '--output',
                        default='./',
                        dest='output',
                        help='output directory')
    argparser.add_argument('-d', '--create-directory', action='store_true',
                        help='Create \'ExportOptions\' directory')
    argparser.add_argument('bundle_id',
                        help='Bundle Identifier')
    return argparser.parse_args()

if __name__ == "__main__":
    args = parse()
    main(args)
