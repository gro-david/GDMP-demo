#!/usr/bin/python

import os
import sys
from os import listdir as lsdir
from os import makedirs as mkdir
from os import path, remove, rmdir
from shutil import copyfile as copy
from shutil import move
from subprocess import run

godot_project = path.join(path.dirname(__file__), 'project')
mediapipe_path = path.join(path.dirname(__file__), 'GDMP', 'mediapipe')
custom_path = path.join(path.dirname(__file__), 'mediapipe')


def custom_setup(src, dst):
    """
    Copy custom mediapipe files to mediapipe workspace.
    Custom directories that does not exists in workspace will be created.
    If file to copy already exists, original file will be renamed with .orig extension.
    """
    for root, dirs, files in os.walk(src):
        rel = path.relpath(root, src)
        try:
            for dir in dirs:
                dirname = path.join(dst, rel, dir)
                if not path.exists(dirname):
                    mkdir(dirname)
                    print("\tCreated %s" % dirname)
            for file in files:
                filename = path.join(dst, rel, file)
                if path.exists(filename):
                    move(filename, filename + '.orig')
                copy(path.join(root, file), filename)
                print("\tCreated %s" % filename)
        except Exception as e:
            print(e)
            continue


def custom_cleanup(src, dst):
    """
    Remove custom mediapipe files from mediapipe workspace.
    Only files that exists in custom path will be removed, will also rename .orig file back if exists.
    Only empty directories will be removed from workspace.
    """
    for root, dirs, files in reversed(list(os.walk(src))):
        rel = path.relpath(root, src)
        try:
            for file in files:
                filename = path.join(dst, rel, file)
                if path.exists(filename):
                    remove(filename)
                    print("\tRemoved %s" % filename)
                if path.exists(filename + '.orig'):
                    move(filename + '.orig', filename)
            for dir in dirs:
                dirname = path.join(dst, rel, dir)
                if not lsdir(dirname):
                    rmdir(dirname)
                    print("\tRemoved %s" % dirname)
        except Exception as e:
            print(e)
            continue


if custom_path:
    os.chdir(path.dirname(__file__))
    print("Custom files: setting up...")
    custom_setup(custom_path, mediapipe_path)

try:
    os.environ['GODOT_PROJECT'] = godot_project
    run([sys.executable, 'GDMP/build.py'] + sys.argv[1:])
except BaseException as e:
    print(e)

if custom_path:
    os.chdir(path.dirname(__file__))
    print("Custom files: cleaning up...")
    custom_cleanup(custom_path, mediapipe_path)
